# CS 424: Programming Assignment 1
# Author: Isaiah Harville
# Date:   6/14/2024
# Tested on: Windows 10

using Printf
using FileIO
using Statistics

struct Student
    first_name::String
    last_name::String
    test_grades::Vector{Int}
    homework_grades::Vector{Int}
    test_avg::Int
    hw_avg::Int
    ovrl_avg::Int
end

function get_inputs()
    println("Input File Name: ")
    file_name = readline()
    if !occursin(".txt", file_name)
        file_name *= ".txt"
    end

    println("Test Weight (%): ")
    test_weight = parse(Int, readline())

    println("\nTest Weight: $test_weight%,  Homework Weight: $(100 - test_weight)%\n")

    println("Number of Homework Assignments: ")
    assignment_len = parse(Int, readline())

    println("Number of Tests: ")
    test_len = parse(Int, readline())

    return file_name, assignment_len, test_len, test_weight
end

function read_scores(scores::Vector{String}, given_len::Int)
    if given_len > length(scores)
        @warn "Given length ($given_len) is longer than actual length ($(length(scores)))"
        given_len = length(scores)
    end

    retyped_scores = Int[]
    for i in 1:given_len
        try
            push!(retyped_scores, parse(Int, scores[i]))
        catch e
            println(e)
        end
    end
    return retyped_scores
end

function collect_data(file_name::String, assignment_len::Int, test_len::Int, test_weight::Int)
    students = Student[]
    overall_sum = 0

    file = open(file_name, "r")
    lines = readlines(file)
    close(file)

    line_num = 0
    current = Student("", "", Int[], Int[], 0, 0, 0)

    while line_num < length(lines)
        partitioned_line = split(lines[line_num])

        if line_num % 3 == 0
            current = Student(partitioned_line[1], partitioned_line[2], Int[], Int[], 0, 0, 0)
        elseif line_num % 3 == 1
            current.test_grades = read_scores(partitioned_line, test_len)
        elseif line_num % 3 == 2
            current.homework_grades = read_scores(partitioned_line, assignment_len)
            current.test_avg = weighted_average(current.test_grades, test_weight)
            current.hw_avg = weighted_average(current.homework_grades, 100 - test_weight)
            current.ovrl_avg = current.test_avg + current.hw_avg
            overall_sum += current.ovrl_avg
            push!(students, current)
        end
        line_num += 1
    end

    return students, overall_sum
end

function print_data(students::Vector{Student}, test_weight::Int, hw_len::Int, test_len::Int, overall_sum::Int)
    println()
    println("GRADE REPORT --- $(length(students)) STUDENTS FOUND IN FILE")
    println("TEST WEIGHT: $test_weight%")
    println("HOMEWORK WEIGHT: $(100 - test_weight)%")
    println("OVERALL AVERAGE: $(overall_sum ÷ length(students))%\n")

    println("        STUDENT NAME           :       TESTS     HOMEWORKS      OVERALL")
    println("----------------------------------------------------------------------")
    for student in students
        @printf("\n\t%s, %-15s : %8d (%d) %6d (%d) %10d",
            student.last_name, student.first_name,
            student.test_avg, length(student.test_grades),
            student.hw_avg, length(student.homework_grades),
            student.ovrl_avg)

        if length(student.test_grades) < test_len && length(student.homework_grades) < hw_len
            print("\t  ** may be missing a test and homework grade **")
        elseif length(student.test_grades) < test_len
            print("\t  ** may be missing a test grade **")
        elseif length(student.homework_grades) < hw_len
            print("\t  ** may be missing a homework grade **")
        end
    end
    println()
end

function weighted_average(scores::Vector{Int}, weight::Int)
    sum = sum(scores)
    average = sum ÷ length(scores)
    return average * weight ÷ 100
end

function main()
    file_name, assignment_len, test_len, test_weight = get_inputs()
    students, overall_sum = collect_data(file_name, assignment_len, test_len, test_weight)
    print_data(students, test_weight, assignment_len, test_len, overall_sum)
end

main()
