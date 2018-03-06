def zero
    0
end

def increment(n)
    n + 1
end

def recurse(f,g,*values)
    *other_values, last_value = values

    if last_value.zero?
        send(f, * other_values)
    else
        easier_last_value = last_value - 1
        easier_values = other_values + [easier_last_value]

        easier_result = recurse(f,g, *easier_values)
        send(g, * easier_values,easier_result)
    end
end

def minimize
    n = 0
    n = n + 1 until yield(n).zero?
    n
end


def add_zero_to_x(x)
    x
end

def increment_easier_result(x, easier_y,easier_result)
    increment(easier_result)
end

def add(x,y)
    recurse(:add_zero_to_x,:increment_easier_result,x,y)
end

def multiply_x_by_zero(x)
    zero
end

def add_x_to_easier_result(x,easier_y,easier_result)
    add(x,easier_result)
end

def multiply(x,y)
    recurse(:multiply_x_by_zero, :add_x_to_easier_result,x,y)
end

def easier_x(easier_x,easier_result)
    easier_x
end

def decrement(x)
    recurse(:zero,:easier_x,x)
end

def subtract_zero_from_x(x)
    x
end

def decrement_easier_result(x,easier_y,easier_result)
    decrement(easier_result)
end

def subtract(x,y)
    recurse(:subtract_zero_from_x,:decrement_easier_result,x,y)
end

def divide(x,y)
    minimize { |n| subtract(increment(x),multiply(y,increment(n)))}
end

# add(3,5)