class Number < Struct.new(:value)
    def to_s
        value.to_s
    end

    def inspect
        "#{self}"
    end

    def reducible?
        false
    end

    def evaluate(environment)
        self
		end
		
		def to_ruby
			"-> e { #{value.inspect}}"
		end
end

class Boolean < Struct.new(:value)
    def to_s
        value.to_s
    end

    def inspect
        "#{self}"
    end

    def reducible?
        false
    end

    def evaluate(environment)
        self
		end
		
		def to_ruby
			"-> e { #{value.inspect}}"
		end
end

class Variable < Struct.new(:name)
    def to_s
        name.to_s
    end

    def inspect
        "#{self}"
    end

    def reducible?
        true
    end

    def reduce(environment)
        environment[name]
    end

    def evaluate(environment)
        environment[name]
    end

    def to_ruby
        "-> e { e[#{name.inspect}] }"
    end
end

class Add < Struct.new(:left, :right)
    def to_s
        "#{left} + #{right}"
    end

    def inspect
        "#{self}"
    end

    def reducible?
        true
    end

    def reduce(environment)
        if left.reducible?
            Add.new(left.reduce(environment),right)
        elsif right.reducible?
            Add.new(left,right.reduce(environment))
        else
            Number.new(left.value + right.value)
        end
    end

    def evaluate(environment)
        Number.new(left.evaluate(environment).value + right.evaluate(environment).value)
    end

    def to_ruby
        "-> e { (#{left.to_ruby}).call(e) + (#{right.to_ruby}).call(e) }"
    end
end

class Multiply < Struct.new(:left, :right)
    def to_s
        "#{left} * #{right}"
    end

    def inspect
        "#{self}"
    end

    def reducible?
        true
    end

    def reduce(environment)
        if left.reducible?
            Add.new(left.reduce(environment),right)
        elsif right.reducible?
            Add.new(left,right.reduce(environment))
        else
            Number.new(left.value * right.value)
        end
    end
    
    def evaluate(environment)
        Number.new(left.evaluate(environment).value * right.evaluate(environment).value)
    end

    def to_ruby
        "-> e { (#{left.to_ruby}).call(e) * (#{right.to_ruby}).call(e) }"
    end
end

class LessThan < Struct.new(:left, :right)
    def to_s
        "#{left} < #{right}"
    end

    def inspect
        "#{self}"
    end

    def reducible?
        true
    end

    def reduce(environment)
        if left.reducible?
            LessThan.new(left.reduce(environment), right)
        elsif right.reducible?
            LessThan.new(left,right.reduce(environment))
        else
            Boolean.new(left.value < right.value)
        end
    end

    def evaluate(environment)
        Boolean.new(left.evaluate(environment).value < right.evaluate(environment).value)
    end

    def to_ruby
        "-> e { (#{left.to_ruby}).call(e) < (#{right.to_ruby}).call(e) }"
    end
end

class Assign < Struct.new(:name ,:expression)
    def to_s
        "#{name} = #{expression}"
    end

    def inspect
        "<<#{self}>>"
    end

    def reducible?
        true
    end

    def reduce(environment)
        if expression.reducible?
            [Assign.new(name,expression.reduce(environment)),environment]
        else
            [DoNothing.new,environment.merge({ name => expression })]
        end
    end

    def evaluate(environment)
        environment.merge({ name => expression.evaluate(environment)})
    end

    def to_ruby
        "-> e {e.merge({ #{name.inspect} => (#{expression.to_ruby}).call(e)})} "
    end
end

class DoNothing
    def to_s
        'do-nothing'
    end
    def inspect
        "<<#{self}>>"
    end
    def == (other_statement)
        other_statement.instance_of?(DoNothing)
    end

    def reducible?
        false
    end

    def evaluate(environment)
        environment
    end

    def to_ruby
        '-> e { e }'
    end
end

class If < Struct.new(:condition, :consequence, :alternative)
    def to_s
        "if (#{condition} {#{consequence}} else { #{alternative} })"
    end

    def inspect
        "<<#{self}>>"
    end

    def reducible?
        true
    end

    def reduce(environment)
        if condition.reducible?
            [If.new(condition.reduce(environment), consequence, alternative),environment]
        else
            case condition
            when Boolean.new(true)
                [consequence, environment]
            when Boolean.new(false)
                [alternative, environment]
            end
        end
	end
		
		def evaluate(environment)
			case condition.evaluate(environment)
			when Boolean.new(true)
				consequence.evaluate(environment)
			when Boolean.new(false)
				alternative.evaluate(environment)
			end
        end

    def to_ruby
        "-> e { if (#{condition.to_ruby}).call(e)" +
          "then (#{consequence.to_ruby}).call(e)" +
          "else (#{alternative.to_ruby}).call(e)" +
          "end }"
    end
end

class Sequence < Struct.new(:first, :second)
	def to_s
			"#{first}; #{second}"
	end

	def inspect
			"<<#{self}>>"
	end

	def reducible?
			true
	end

	def reduce(environment)
			case first
			when DoNothing.new
					[second,environment]
			else
					reduce_first, reduce_enviroment = first.reduce(environment)
					[Sequence.new(reduce_first,second), reduce_enviroment]
			end
	end

	def evaluate(environment)
		second.evaluate(first.evaluate(environment))
    end
    
    def to_ruby
        "-> e { (#{second.to_ruby}).call((#{first.to_ruby}).call(e)) }"
    end
end

class While < Struct.new(:condition, :body)
	def to_s
			"while (#{condition}) { #{body} }"
	end

	def inspect
			"<<#{self}>>"
	end

	def reducible?
			true
	end

	def reduce(environment)
			[If.new(condition,Sequence.new(body, self), DoNothing.new), environment]
	end

	def evaluate(environment)
		case condition.evaluate(environment)
		when Boolean.new(true)
			evaluate(body.evaluate(environment))
		when Boolean.new(false)
			environment
		end
    end
    
    def to_ruby
        "-> e {" +
          "while (#{condition.to_ruby}).call(e); e = (#{body.to_ruby}).call(e); end;" +
          " e" +
          "}"
    end
end

# Number.new(23).evaluate({})
# Variable.new(:x).evaluate({ x: Number.new(23)})
# LessThan.new(
#     Add.new(Variable.new(:x),Number.new(2)),
#     Variable.new(:y)
# ).evaluate({ x: Number.new(2), y: Number.new(5)})

# statement = Sequence.new(Assign.new(:x, Add.new(Number.new(1),Number.new(1))),Assign.new(:y, Add.new(Variable.new(:x), Number.new(3))))
# statement.evaluate({})
# statement = While.new(LessThan.new(Variable.new(:x), Number.new(5)), Assign.new(:x,Multiply.new(Variable.new(:x),Number.new(3))))
# statement.evaluate({x: Number.new(1)})
# Add.new(Variable.new(:x), Number.new(1)).to_ruby
# LessThan.new(Add.new(Variable.new(:x), Number.new(1)), Number.new(3)).to_ruby
# proc = eval(LessThan.new(Add.new(Variable.new(:x),Number.new(1)),Number.new(3)).to_ruby)
# proc.call(environment)

# statement = Assign.new(:y, Add.new(Variable.new(:x), Number.new(1)))
# statement.to_ruby
# proc = eval(statement.to_ruby)
# proc.call({x: 3})

# statement = While.new(LessThan.new(Variable.new(:x), Number.new(5)),Assign.new(:x,Multiply.new(Variable.new(:x), Number.new(3))))
# statement.to_ruby
# proc = eval(statement.to_ruby)
# proc.call({x:1})
