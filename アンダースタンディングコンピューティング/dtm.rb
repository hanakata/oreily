class Tape < Struct.new(:left,:middle,:right,:blank)
    def inspect
        "Tape #{left.join}(#{middle})#{right.join}>"
    end

    def write(character)
        Tape.new(left,character,right,blank)
    end

    def move_head_left
        Tape.new(left[0..-2],left.last || blank, [middle] + right, blank)
    end

    def move_head_right
        Tape.new(left + [middle],right.first || blank,right.drop(1),blank)
    end
end

class TMConfiguration < Struct.new(:state, :tape)
end

class TMRule < Struct.new(:state,:character,:next_state,:write_character,:direction)
    def applies_to?(configuration)
        state == configuration.state && character == configuration.tape.middle
    end

    def follow(configuration)
        TMConfiguration.new(next_state,next_tape(configuration))
    end

    def next_tape(configuration)
        written_tape = configuration.tape.write(write_character)

        case direction
        when :left
            written_tape.move_head_left
        when :right
            written_tape.move_head_right
        end
    end
end

class DTMRulebook < Struct.new(:rules)
    def next_configuration(configuration)
        rule_for(configuration).follow(configuration)
    end

    def rule_for(configuration)
        rules.detect { |rule| rule.applies_to?(configuration)}
    end

    def applies_to?(configuration)
        !rule_for(configuration).nil?
    end
end

class DTM < Struct.new(:current_configuration,:accept_states,:rulebook)
    def accepting?
        accept_states.include?(current_configuration.state)
    end

    def step
        self.current_configuration = rulebook.next_configuration(current_configuration)
    end

    def run
        step until accepting? || stuck?
    end

    def stuck?
        !accepting? && !rulebook.applies_to?(current_configuration)
    end

end

# tape = Tape.new(['1','0','1'],'1',[],'_')
# rule = TMRule.new(1,'0',2,'1',:right)

# rulebook = DTMRulebook.new([
#     TMRule.new(1,'0',2,'1',:right),
#     TMRule.new(1,'1',1,'0',:left),
#     TMRule.new(1,'_',2,'1',:right),
#     TMRule.new(2,'0',2,'0',:right),
#     TMRule.new(2,'1',2,'1',:right),
#     TMRule.new(2,'_',3,'_',:left),
# ])

# tape.middle
# tape
# tape.move_head_left
# tape.write('0')
# tape.move_head_right
# tape.move_head_right.write('0')

# rule.applies_to?(TMConfiguration.new(1,Tape.new([],'0',[],'_')))
# rule.applies_to?(TMConfiguration.new(1,Tape.new([],'1',[],'_')))
# rule.applies_to?(TMConfiguration.new(2,Tape.new([],'0',[],'_')))

# rule.follow(TMConfiguration.new(1,Tape.new([],'0',[],'_')))

# configuration = TMConfiguration.new(1,tape)
# configuration = rulebook.next_configuration(configuration)
# configuration = rulebook.next_configuration(configuration)
# configuration = rulebook.next_configuration(configuration)

# dtm = DTM.new(TMConfiguration.new(1,tape),[3],rulebook)
# dtm.current_configuration
# dtm.accepting?
# dtm.step;dtm.current_configuration
# dtm.accepting?
# dtm.run
# dtm.current_configuration
# dtm.accepting?
# dtm.stuck?