addTestRecord() {
    echo "Please Enter Patient ID (please enter exactly 7 digits):"
    read patientID
    count=$(echo -n "$patientID" | wc -c)
    while [ "$count" -ne 7 ] && ! echo "$count" | grep -q '[A-Za-z]'; do
        echo "Wrong input, please make sure that the ID has 7 digits"
        read patientID
        count=$(echo -n "$patientID" | wc -c)
    done

    echo "Please Enter Test Name"
    read name
    while echo "$name" | grep -q '[0-9]'; do
        echo "Wrong input"
        read name
    done

    echo "Please Enter Date (YYYY-MM)"
    read date
    while ! echo "$date" | grep -q '^[0-9]\{4\}-[0-9]\{2\}'; do
        echo "Wrong input"
        read date
    done

    echo "Please enter result (float number):"
    read result
    while ! echo "$result" | grep -q '^[0-9]*\.[0-9]*$' && ! echo "$result" | grep -q '^[0-9]*$'; do 
        echo "Wrong input"
        read result
    done

    echo "Please enter unit (g/dL, mg/dL, mm Hg):"
    read unit
    while true; do
        if [ "$unit" = 'g/dL' ] || [ "$unit" = 'mg/dL' ] || [ "$unit" = 'mm Hg' ]; then
            break
        else
            echo "Wrong input"
            read unit
        fi
    done

    echo "Please enter status (pending, completed, reviewed):" 
    read status
    status=$(echo "$status" | tr '[A-Z]' '[a-z]')
    while true; do
        if [ "$status" = "pending" ] || [ "$status" = "completed" ] || [ "$status" = "reviewed" ]; then
            break
        else
            echo "Invalid Status. Must be one of: pending, completed, reviewed."
            read status
            status=$(echo "$status" | tr '[A-Z]' '[a-z]')
        fi
    done

    echo "$patientID: $name, $date, $result, $unit, $status" >> medicalRecord.txt
    echo "Successful"
}

searchByPatientId() {
    echo "Please Enter Patient ID (please enter exactly 7 digits):"
    read patient_id
    count=$(echo -n "$patient_id" | wc -c)
    while [ "$count" -ne 7 ] && ! echo "$count" | grep -q '[A-Za-z]'; do
        echo "Wrong input, please make sure that the ID has 7 digits"
        read patient_id
        count=$(echo -n "$patient_id" | wc -c)
    done

    echo "1. Retrieve all patient tests"
    echo "2. Retrieve all abnormal patient tests"
    echo "3. Retrieve all patient tests in a specific period"
    echo "4. Retrieve all patient tests based on test status"
    echo -n "Enter your choice [1-4]:"
    read search_option

    case $search_option in
        1)
            grep "^$patient_id:" medicalRecord.txt
            ;;
        2)
            grep "^$patient_id:" medicalRecord.txt | while IFS=',' read -r id_name date result unit status; do
                test_name=$(echo "$id_name" | cut -d':' -f2 | tr -d ' ')
                result=$(echo "$result" | tr -d ' ')
                normal_range=$(grep "^$test_name;" medicalTest.txt | cut -d';' -f2 | tr -d ' ')
                
                # Parse normal range
                min_range=$(echo "$normal_range" | grep -oE '> ?[0-9]+\.?[0-9]*' | cut -d'>' -f2)
                max_range=$(echo "$normal_range" | grep -oE '< ?[0-9]+\.?[0-9]*' | cut -d'<' -f2)
                
                # Check if the result is abnormal
                if ( [ -n "$min_range" ] && (( $(echo "$result <= $min_range" | awk '{print ($1 < $2)}') )) ) || \
                   ( [ -n "$max_range" ] && (( $(echo "$result >= $max_range" | awk '{print ($1 > $2)}') )) ); then
                    echo "$id_name, $date, $result, $unit, $status"
                fi
            done
            ;;
        3)
            echo -n "Enter start date (YYYY-MM): "
            read start_date
            echo -n "Enter end date (YYYY-MM): "
            read end_date
            grep "^$patient_id:" medicalRecord.txt | while read line; do
                test_date=$(echo "$line" | cut -d, -f2 | cut -d' ' -f2)
                if [[ "$test_date" > "$start_date" && "$test_date" < "$end_date" ]]; then
                    echo "$line"
                fi
            done
            ;;
        4)
            echo -n "Enter status (Pending, Completed, Reviewed):"
            read status
            status=$(echo "$status")
            while true; do
                if [ "$status" = "Pending" ] || [ "$status" = "Completed" ] || [ "$status" = "Reviewed" ]; then
                    break
                else
                    echo "Invalid Status. Must be one of: Pending, Completed, Reviewed."
                    read status
                    status=$(echo "$status")
                fi
            done
            grep "^$patient_id:" medicalRecord.txt | grep "$status"
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
}

updateTestResult() {
    echo "Please enter patient ID:"
    read patientID
    count=$(echo -n "$patientID" | wc -c)
    while [ "$count" -ne 7 ] || echo "$patientID" | grep -q '[^0-9]'; do
        echo "Wrong input, please make sure that the ID has 7 digits"
        read patientID
        count=$(echo -n "$patientID" | wc -c)
    done

    echo "Please Enter Test Name"
    read name
    while echo "$name" | grep -q '[0-9]'; do
        echo "Wrong input"
        read name
    done

    temp=$(sed -n "/$patientID: $name/p" medicalRecord.txt)
    if [ -z "$temp" ]; then
        echo "No record found for Patient ID: $patientID and Test Name: $name."
        return
    fi

    sed "/$patientID: $name/d" medicalRecord.txt > tempFile.txt
    echo "Please enter a new result:"
    read result
    while ! echo "$result" | grep -q '^[0-9]*\.[0-9]*$' && ! echo "$result" | grep -q '^[0-9]*$'; do 
        echo "Wrong input"
        read result
    done

    temp2=$(echo "$temp" | cut -d' ' -f4)
    temp=$(echo "$temp" | sed "s/$temp2/$result/")
    echo "$temp" >> tempFile.txt
    mv tempFile.txt medicalRecord.txt
    echo "Record updated successfully."
}

retrieveAverageTestValues() {
    # extract unique test names from the medical records
    test_names=$(cut -d',' -f1 medicalRecord.txt | cut -d':' -f2 | sed 's/^ *//;s/ *$//' | sort | uniq)

    # loop through each test name and calculate the average
    for name in $test_names; do
        # extract all results for the current test name
        results=$(grep ": $name," medicalRecord.txt | cut -d',' -f3 | tr -d ' ')

        # initialize sum and count for averaging
        sum=0
        count=0

        # calculate sum and count using awk
        for value in $results; do
            sum=$(awk -v sum="$sum" -v value="$value" 'BEGIN {print sum + value}')
            count=$((count + 1))
        done

        # calculate average if count is not zero
        if [ $count -ne 0 ]; then
            average=$(awk -v sum="$sum" -v count="$count" 'BEGIN {printf "%.2f", sum / count}')
            echo "Average for $name = $average"
        else
            echo "No values found for Test Name: $name."
        fi
    done
}




show_menu() {
    echo "Medical Record Management System"
    echo "1. Add a new medical test record"
    echo "2. Search for tests by patient ID"
    echo "3. Update an existing test result"
    echo "4. Retrieve average test values"
    echo "5. Exit"
    echo -n "Enter your choice [1-5]: "
}

while true; do
    show_menu
    read choice
    case $choice in
        1) addTestRecord ;;
        2) searchByPatientId ;;
        3) updateTestResult ;;
         4) retrieveAverageTestValues ;;
        5) exit 0 ;;
        *) echo "Invalid choice. Please enter a number between 1 and 5." ;;
    esac
done
