require 'set'

class FARule < Struct.new(:state, :character, :next_state)
    def applies_to?(state, character)
        self.state == state && self.character == character
    end

    def follow
        next_state
    end

    def inspect
        "<FARule #{state.inspect} --#{character}--> #{next_state.inspect}>"
    end
end

class DFARulebook < Struct.new(:rules)
    def next_state(state, character)
        rule_for(state, character).follow
    end

    def rule_for(state, character)
        rules.detect { |rule| rule.applies_to?(state, character)}
    end
end

class DFA < Struct.new(:current_state, :accept_states, :rulebook)
    def accepting?
        accept_states.include?(current_state)
    end

    def read_character(character)
        self.current_state = rulebook.next_state(current_state,character)
    end

    def read_string(string)
        string.chars.each do |character|
            read_character(character)
        end
    end
end

class DFADesign < Struct.new(:start_state, :accept_states, :rulebook)
    def to_dfa
        DFA.new(start_state,accept_states,rulebook)
    end

    def accepts?(string)
        to_dfa.tap { |dfa| dfa.read_string(string)}.accepting?
    end
end

class NFARulebook < Struct.new(:rules)
    def next_states(states, character)
        states.flat_map { |state| follow_rules_for(state, character)}.to_set
    end

    def follow_rules_for(state, character)
        rules_for(state,character).map(&:follow)
    end

    def rules_for(state, character)
        rules.select { |rule| rule.applies_to?(state, character) }
    end

    def follow_free_moves(states)
        more_states = next_states(states, nil)

        if more_states.subset?(states)
            states
        else
            follow_free_moves(states + more_states)
        end
    end

    def alphabet
        rules.map(&:character).compact.uniq
    end
end

class NFA < Struct.new(:current_states, :accept_states, :rulebook)
    def accepting?
        (current_states & accept_states).any?
    end

    def read_character(character)
        self.current_states = rulebook.next_states(current_states, character)
    end

    def read_string(string)
        string.chars.each do |character|
            read_character(character)
        end
    end

    def current_states
        rulebook.follow_free_moves(super)
    end
end

class NFADesign < Struct.new(:start_state,:accept_states,:rulebook)
    def accepts?(string)
        to_nfa.tap { |nfa| nfa.read_string(string) }.accepting?
    end

    def to_nfa(current_states = Set[start_state])
        NFA.new(current_states, accept_states,rulebook)
    end
end

module Pattern
    def bracket(outer_precedence)
        if precedence < outer_precedence
            '(' + to_s + ')'
        else
            to_s
        end
    end

    def inspect
        "/#{self}/"
    end

    def matches?(string)
        to_nfa_design.accepts?(string)
    end
end

class Empty
    include Pattern

    def to_s
        ''
    end
    def precedence
        3
    end

    def to_nfa_design
        start_state = Object.new
        accept_states = [start_state]
        rulebook = NFARulebook.new([])

        NFADesign.new(start_state,accept_states,rulebook)
    end
end

class Literal < Struct.new(:character)
    include Pattern

    def to_s
        character
    end

    def precedence
        3
    end

    def to_nfa_design
        start_state = Object.new
        accept_state = Object.new
        rule = FARule.new(start_state,character,accept_state)
        rulebook = NFARulebook.new([rule])

        NFADesign.new(start_state, [accept_state], rulebook)
    end
end

class Concatenate < Struct.new(:first, :second)
    include Pattern
    
    def to_s
        [first,second].map { |pattern| pattern.bracket(precedence) }.join
    end

    def precedence
        0
    end

    def to_nfa_design
        first_nfa_design = first.to_nfa_design
        second_nfa_design = second.to_nfa_design

        start_state = first_nfa_design.start_state
        accept_states = second_nfa_design.accept_states
        rules = first_nfa_design.rulebook.rules + second_nfa_design.rulebook.rules
        extra_rules = first_nfa_design.accept_states.map { |state|
            FARule.new(state,nil,second_nfa_design.start_state)
        }
        rulebook = NFARulebook.new(rules + extra_rules)

        NFADesign.new(start_state,accept_states,rulebook)
    end
end

class Choose < Struct.new(:first,:second)
    include Pattern

    def to_s
        [first,second].map { |pattern| pattern.bracket(precedence) }.join('|')
    end

    def precedence
        1
    end

    def to_nfa_design
        first_nfa_design = first.to_nfa_design
        second_nfa_design = second.to_nfa_design

        start_state = Object.new
        accept_states = first_nfa_design.accept_states + second_nfa_design.accept_states
        rules = first_nfa_design.rulebook.rules + second_nfa_design.rulebook.rules
        extra_rules = [first_nfa_design,second_nfa_design].map { |nfa_design|
            FARule.new(start_state,nil,nfa_design.start_state)
        }
        rulebook = NFARulebook.new(rules + extra_rules)

        NFADesign.new(start_state,accept_states,rulebook)
    end
end

class Repeat < Struct.new(:pattern)
    include Pattern

    def to_s
        pattern.bracket(precedence) + '*'
    end

    def precedence
        2
    end

    def to_nfa_design
        pattern_nfa_defign = pattern.to_nfa_design

        start_state = Object.new
        accept_states = pattern_nfa_defign.accept_states + [start_state]
        rules = pattern_nfa_defign.rulebook.rules
        extra_rules = 
          pattern_nfa_defign.accept_states.map { |accept_state| 
            FARule.new(accept_state, nil, pattern_nfa_defign.start_state)
          } + 
          [FARule.new(start_state,nil,pattern_nfa_defign.start_state)]
        rulebook = NFARulebook.new(rules + extra_rules)

        NFADesign.new(start_state,accept_states,rulebook)
    end
end

class NFASimulation < Struct.new(:nfa_design)
    def next_state(state, character)
        nfa_design.to_nfa(state).tap { |nfa|
            nfa.read_character(character)
         }.current_states
    end
    
    def rules_for(state)
        nfa_design.rulebook.alphabet.map { |character|
            FARule.new(state, character, next_state(state, character))
        }
    end

    def discover_state_and_rules(states)
        rules = states.flat_map { |state| rules_for(state) }
        more_states = rules.map(&:follow).to_set

        if more_states.subset?(states)
            [states,rules]
        else
            discover_state_and_rules(states + more_states)
        end
    end

    def to_dfa_design
        start_state = nfa_design.to_nfa.current_states
        states,rules = discover_state_and_rules(Set[start_state])
        accept_states = states.select { |state| nfa_design.to_nfa(state).accepting?}

        DFADesign.new(start_state, accept_states,DFARulebook.new(rules))
    end
end

rulebook = NFARulebook.new([
    FARule.new(1,'a',1),FARule.new(1,'a',2),FARule.new(1,nil,2),
    FARule.new(2,'b',3),
    FARule.new(3,'b',1),FARule.new(3,nil,2),
])
nfa_design = NFADesign.new(1,[3],rulebook)
simulation = NFASimulation.new(nfa_design)
start_state = nfa_design.to_nfa.current_states
dfa_design = simulation.to_dfa_design

# nfa_design.to_nfa.current_states
# nfa_design.to_nfa(Set[2]).current_states
# nfa_design.to_nfa(Set[3]).current_states

# simulation.next_state(Set[1,2], 'a')
# simulation.next_state(Set[1,2], 'b')
# simulation.next_state(Set[3,2], 'b')
# rulebook.alphabet
# simulation.rules_for(Set[1,2])
# simulation.rules_for(Set[3,2])

# simulation.discover_state_and_rules(Set[start_state])
# nfa_design.to_nfa(Set[1,2]).accepting?
# nfa_design.to_nfa(Set[2,3]).accepting?

# dfa_design.accepts?('aaa')
# dfa_design.accepts?('aab')
# dfa_design.accepts?('bbbab')
