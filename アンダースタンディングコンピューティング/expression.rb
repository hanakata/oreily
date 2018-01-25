class Number < Struct.new(:value)
end

class Add < Struct.new(:left, :right)
end

class Multiply < Struct.new(:left, :right)
end

class Number
    def to_s
        value.to_s
    end

    def inspect
        "<<#{self}>>"
    end

    def reducible?
        false
    end
end

class Add
    def to_s
        "<<#{left} + #{right}>>"
    end

    def inspect
        "<<#{self}>>"
    end

    def reducible?
        true
    end

    def reduce
        if left.reducible?
            Add.new(left.reduce,right)
        elsif right.reducible?
            Add.new(left,right.reduce)
        else
            Number.new(left.value + right.value)
        end
    end
end

class Multiply
    def to_s
        "<<#{left} * #{right}>>"
    end

    def inspect
        "<<#{self}>>"
    end

    def reducible?
        true
    end

    def reduce
        if left.reducible?
            Add.new(left.reduce,right)
        elsif right.reducible?
            Add.new(left,right.reduce)
        else
            Number.new(left.value * right.value)
        end
    end

end

expression = 
    Add.new(
        Multiply.new(Number.new(1), Number.new(2)),
        Multiply.new(Number.new(3), Number.new(4))
    )

expression.reducible?
expression = expression.reduce
expression.reducible?
expression = expression.reduce
expression.reducible?
expression = expression.reduce
expression.reducible?