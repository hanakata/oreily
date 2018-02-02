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


#rulebook = DFARulebook.new([FARule.new(1,'a',2),FARule.new(1,'b',1),FARule.new(2,'a',2),FARule.new(2,'b',3),FARule.new(3,'a',3),FARule.new(3,'b',3)])
#rulebook.next_state(3,'a')

# DFA.new(1,[1,3],rulebook).accepting?
# DFA.new(1,[3],rulebook).accepting?

# dfa = DFA.new(1,[3],rulebook); dfa.accepting?
# dfa.read_character('b'); dfa.accepting?
# 3.times do dfa.read_character('a') end; dfa.accepting?
# dfa.read_character('b'); dfa.accepting?

# dfa = DFA.new(1,[3],rulebook);dfa.accepting?
# dfa.read_string('baaab'); dfa.accepting?

# dfa_design = DFADesign.new(1,[3], rulebook)
# dfa_design.accepts?('a')
# dfa_design.accepts?('baa')
# dfa_design.accepts?('baba')