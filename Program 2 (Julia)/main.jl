using Printf
using Statistics

struct Student
    first_name::String
    last_name::String
    test_grades::Vector{Int}
    homework_grades::Vector{Int}
    test_avg::Float64
    hw_avg::Float64
    ovrl_avg::Float64
end

function get_inputs()
    println("Input File Name: ")
    file_name = String(strip(readline()))
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

function read_scores(line::String, expected_count::Int)
    scores = split(line)
    if length(scores) != expected_count
        println("Warning: Expected $expected_count scores, but got $(length(scores))")
    end
    return parse.(Int, scores[1:expected_count])
end

function collect_data(file_name::String, assignment_len::Int, test_len::Int, test_weight::Int)
    students = Student[]
    overall_sum = 0.0

    file = open(file_name, "r")
    lines = readlines(file)
    close(file)

    i = 1
    while i <= length(lines)
        if strip(lines[i]) == ""
            i += 1
            continue
        end

        name_parts = split(lines[i])
        if length(name_parts) < 2
            println("Invalid student name on line $i: ", lines[i])
            i += 1
            continue
        end

        first_name = name_parts[1]
        last_name = name_parts[2]

        test_grades = read_scores(lines[i + 1], test_len)
        homework_grades = read_scores(lines[i + 2], assignment_len)

        test_avg = mean(test_grades) * test_weight / 100
        hw_avg = mean(homework_grades) * (100 - test_weight) / 100
        ovrl_avg = test_avg + hw_avg

        overall_sum += ovrl_avg
        push!(students, Student(first_name, last_name, test_grades, homework_grades, test_avg, hw_avg, ovrl_avg))

        i += 3
    end

    return students, overall_sum / length(students)
end

function print_data(students::Vector{Student}, test_weight::Int, hw_len::Int, test_len::Int, overall_avg::Float64)
    println()
    println("GRADE REPORT --- $(length(students)) STUDENTS FOUND IN FILE")
    println("TEST WEIGHT: $test_weight%")
    println("HOMEWORK WEIGHT: $(100 - test_weight)%")
    println("OVERALL AVERAGE: $overall_avg%\n")

    println("        STUDENT NAME           :       TESTS     HOMEWORKS      OVERALL")
    println("----------------------------------------------------------------------")
    for student in students
        @printf("\n\t%s, %-15s : %8.2f (%d) %6.2f (%d) %10.2f",
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

function main()
    file_name, assignment_len, test_len, test_weight = get_inputs()
    students, overall_avg = collect_data(file_name, assignment_len, test_len, test_weight)
    print_data(students, test_weight, assignment_len, test_len, overall_avg)
end

main()
