class TagRule < Struct.new(:first_character, :append_characters)
    def applies_to?(string)
        string.chars.first == first_character
    end

    def follow(string)
        string + append_characters
    end

    def alphabet
        ([first_character] + append_characters.chars.entries).uniq
    end

    def to_cyclic(encoder)
        CyclicTagRule.new(encoder.encode_string(append_characters))
    end
end

class TagRulebook < Struct.new(:deletion_number,:rules)
    def next_string(string)
        rule_for(string).follow(string).slice(deletion_number..-1)
    end

    def rule_for(string)
        rules.detect { |r| r.applies_to?(string)}
    end

    def applies_to?(string)
        !rule_for(string).nil? && string.length >= deletion_number
    end

    def alphabet
        rules.flat_map(&:alphabet).uniq
    end

    def cyclic_rules(encoder)
        encoder.alphabet.map { |character| cyclic_rule_for(character,encoder)}
    end

    def cyclic_rule_for(character,encoder)
        rule = rule_for(character)

        if rule.nil?
            CyclicTagRule.new('')
        else
            rule.to_cyclic(encoder)
        end
    end

    def cyclic_padding_rules(encoder)
        Array.new(encoder.alphabet.length, CyclicTagRule.new('')) * (deletion_number - 1)
    end

    def to_cyclic(encoder)
        CyclicTagRulebook.new(cyclic_rules(encoder) + cyclic_padding_rules(encoder))
    end
end

class TagSystem < Struct.new(:current_string, :rulebook)
    def step
        self.current_string = rulebook.next_string(current_string)
    end

    def run
        while rulebook.applies_to?(current_string)
            puts current_string
            step
        end

        puts current_string
    end

    def alphabet
        (rulebook.alphabet + current_string.chars.entries).uniq.sort
    end

    def encoder
        CyclicTagEncoder.new(alphabet)        
    end

    def to_cyclic
        TagSystem.new(encoder.encode_string(current_string), rulebook.to_cyclic(encoder))
    end
end

class CyclicTagRule < TagRule
    FIRST_CHARACTER = '1'

    def initialize(append_characters)
        super(FIRST_CHARACTER, append_characters)
    end

    def inspect
        "#<CyclicTagRule #{append_characters.inspect}>"
    end
end

class CyclicTagRulebook < Struct.new(:rules)
    DELETION_NUMBER = 1

    def initialize(rules)
        super(rules.cycle)
    end

    def applies_to?(string)
        string.length >= DELETION_NUMBER
    end

    def next_string(string)
        follow_next_rule(string).slice(DELETION_NUMBER..-1)
    end

    def follow_next_rule(string)
        rule = rules.next

        if rule.applies_to?(string)
            rule.follow(string)
        else
            string
        end
    end
end

class CyclicTagEncoder < Struct.new(:alphabet)
    def encode_string(string)
        string.chars.map{|character| encode_character(character)}.join
    end

    def encode_character(character)
        character_position = alphabet.index(character)
        (0..alphabet.length).map { |n| n == character_position ? '1' : '0' }.join
    end
end

# rulebook = TagRulebook.new(2,[TagRule.new('a','ccdd'),TagRule.new('b','dd')])
# system = TagSystem.new('aabbbb',rulebook)
# system.alphabet

# encoder = system.encoder
# encoder.encode_character('c')
# encoder.encode_string('cab')

# cyclic_system = system.to_cyclic
# cyclic_system.run