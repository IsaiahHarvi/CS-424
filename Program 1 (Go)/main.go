// CS 424: Programming Assignment 1
// Author: Isaiah Harville
// Date:   6/14/2024
package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"

	"github.com/sirupsen/logrus"
)

type Student struct {
	first_name      string
	last_name       string
	test_grades     []int
	homework_grades []int
	test_avg        int
	hw_avg          int
	ovrl_avg        int // given by (test_avg + hw_avg)
}

func main() {
	var file_name string
	var assignment_len int
	var test_len int
	var test_weight int
	var overall_sum int
	var students []Student

	_get_inputs(&file_name, &assignment_len, &test_len, &test_weight)

	_collect_data(&students, file_name, assignment_len, test_len, test_weight, &overall_sum)

	_print_data(students, test_weight, assignment_len, test_len, overall_sum)
}

func _get_inputs(file_name *string, assignment_len *int, test_len *int, test_weight *int) {
	/*
		Collects user input for
			file name: where student information is gathered.
			assignment_len: number of homework assignments
			test_len: number of tests
			test_weight: weight of tests in overall grade
		NOTE: homework weight is 100 - test_weight
	*/
	fmt.Print("Input File Name: ")
	fmt.Scan(file_name)
	if !strings.Contains(*file_name, ".txt") { // add .txt if not already present
		*file_name += ".txt"
	}

	fmt.Print("Test Weight (%): ")
	fmt.Scan(test_weight)

	fmt.Printf("\nTest Weight: %d%%,  Homework Weight: %d%%\n", *test_weight, (100 - *test_weight))

	fmt.Print("\nNumber of Homework Assignments: ")
	fmt.Scan(assignment_len)

	fmt.Print("Number of Tests: ")
	fmt.Scan(test_len)
	fmt.Println()
}

func _read_scores(scores []string, given_len int) []int {
	if given_len > len(scores) {
		logrus.Warnf( // log warning if given length is longer than actual length of scores array
			"Given length (%d) is longer than actual length (%d)", given_len, len(scores),
		)
		given_len = len(scores)
	}

	var retyped_scores []int // convert string slice to int slice
	for i := 0; i < given_len; i++ {
		score_int, err := strconv.Atoi(scores[i])
		if err != nil {
			fmt.Print(err)
			continue
		}
		retyped_scores = append(retyped_scores, score_int)
	}
	return retyped_scores
}

func _collect_data( // read student data from file and calculate averages
	students *[]Student, file_name string, assignment_len int,
	test_len int, test_weight int, overall_sum *int,
) {
	// Open file
	file, err := os.Open("txt_files/" + file_name)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	// Read file
	line_num := 0
	scanner := bufio.NewScanner(file)

	// Iterate through file
	var current Student
	for scanner.Scan() {
		line := scanner.Text()
		partitioned_line := strings.Split(line, " ")

		switch line_num % 3 { // lines per student
		case 0:
			current = Student{
				first_name: partitioned_line[0],
				last_name:  partitioned_line[1],
			}
		case 1:
			current.test_grades = _read_scores(partitioned_line, test_len)
		case 2: // last iteration before next student
			current.homework_grades = _read_scores(partitioned_line, assignment_len)
			current.test_avg = _weighted_average(current.test_grades, test_weight)
			current.hw_avg = _weighted_average(current.homework_grades, 100-test_weight)
			current.ovrl_avg = current.test_avg + current.hw_avg
			*overall_sum += current.ovrl_avg
			*students = append(*students, current)
		}
		line_num++
	}
}

func _print_data(students []Student, test_weight int, hw_len int, test_len int, overall_sum int) {
	fmt.Println()
	fmt.Printf("GRADE REPORT --- %d STUDENTS FOUND IN FILE\n", len(students))
	fmt.Printf("TEST WEIGHT: %d%%\n", test_weight)
	fmt.Printf("HOMEWORK WEIGHT: %d%%\n", 100-test_weight)
	fmt.Printf("OVERALL AVERAGE: %d%%\n\n", overall_sum/len(students))

	fmt.Println("        STUDENT NAME           :       TESTS     HOMEWORKS      OVERALL")
	fmt.Print("----------------------------------------------------------------------")
	for _, student := range students {
		fmt.Printf("\n\t%s, %-15s : %8d (%d) %6d (%d) %10d",
			student.last_name, student.first_name,
			student.test_avg, len(student.test_grades),
			student.hw_avg, len(student.homework_grades),
			student.ovrl_avg,
		)
		// print warnings for missing grades
		if len(student.test_grades) < test_len && len(student.homework_grades) < hw_len {
			fmt.Printf("\t  ** may be missing a test and homework grade **")
		} else if len(student.test_grades) < test_len {
			fmt.Printf("\t  ** may be missing a test grade **")
		} else if len(student.homework_grades) < hw_len {
			fmt.Printf("\t  ** may be missing a homework grade **")
		}
	}
	fmt.Println()
}

func _weighted_average(scores []int, weight int) int {
	var sum int
	for _, score := range scores {
		sum += score
	}
	average := sum / len(scores)
	return average * weight / 100
}
