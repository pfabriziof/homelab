#!/usr/bin/env bash

# Budgeting basics: The 50-30-20 rule
#
# Calculate a basic budgeting plan with the 50-30-20 rule for any given monthly income amount.
# You can also choose the number of months for the emergency savings.
#
# The 50-30-20 rule splits expenses into just three categories. It also offers recommendations
# on how much money to use for each. It uses the following categories:
#     Needs: 50%
#         - Utility bills
#         - Rent or mortgage payments
#         - Health care
#         - Groceries
#         - Clothing
#         - Debts
#     Wants: 30%
#         - Subscriptions
#         - Supplies for hobbies
#         - Restaurant meals
#         - Vacations
#         - Games
#     Savings: 20%
#         - Emergency fund
#         - Retirement account
#         - Paying debt beyond the minimum payment

MONTHLY_INCOME=0
NUMBER_MONTHS_SAVES=3
GENERATE_OUTPUT_FILE=false
POSITIONAL_ARGS=()

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Calculate a monthly budget using the 50-30-20 rule."
    echo ""
    echo "Options:"
    echo "  -i, --income <amount>       Your total monthly income as a positive integer (e.g. 3000)."
    echo "                              This is the gross amount before splitting into categories."
    echo ""
    echo "  -m, --months-saves <months> Number of months to target for your emergency fund."
    echo "                              Must be between 3 and 6. Default: 3."
    echo "                              A 3-month fund covers short gaps; 6 months is the recommended"
    echo "                              safety net for most households."
    echo ""
    echo "  -o, --generate-output       Write the budget summary to a file instead of stdout."
    echo ""
    echo "  -h, --help                  Show this help message and exit."
    echo ""
    echo "If no options are provided, the script will prompt you interactively."
}

prompt_income() {
    echo "--- Monthly Income ---"
    echo "Enter your total gross monthly income as a positive integer (e.g. 3000)."
    while true; do
        read -rp "Monthly income: " MONTHLY_INCOME
        if [[ "$MONTHLY_INCOME" =~ ^[1-9][0-9]*$ ]]; then
            break
        else
            echo "  Invalid input. Please enter a positive integer greater than 0."
        fi
    done
}

prompt_months_saves() {
    echo ""
    echo "--- Emergency Fund Duration ---"
    echo "How many months of expenses should your emergency fund cover?"
    echo "  Range:   3–6 months"
    echo "  Default: 3 months"
    echo "  Tip:     3 months covers short gaps; 6 months is the recommended safety net."
    while true; do
        read -rp "Number of months [3]: " input
        input="${input:-3}"
        if [[ "$input" =~ ^[0-9]+$ ]] && (( input >= 3 && input <= 6 )); then
            NUMBER_MONTHS_SAVES="$input"
            break
        else
            echo "  Invalid input. Please enter a number between 3 and 6."
        fi
    done
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--income)
            MONTHLY_INCOME=$2
            shift 2
            ;;
        -m|--months-saves)
            NUMBER_MONTHS_SAVES=$2
            shift 2
            ;;
        -o|--generate-output)
            GENERATE_OUTPUT_FILE=true
            shift 1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*|--*)
            echo "Error: Unknown option $1" >&2
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

# If income was not passed as an argument, enter interactive mode
if [[ "$MONTHLY_INCOME" -eq 0 ]]; then
    echo "No arguments provided. Entering interactive mode."
    echo ""
    prompt_income
    prompt_months_saves
fi

# Validate income is a positive integer
if ! [[ "$MONTHLY_INCOME" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: --income must be a positive integer (got: '$MONTHLY_INCOME')" >&2
    exit 1
fi

# Validate months-saves is between 3 and 6
if ! [[ "$NUMBER_MONTHS_SAVES" =~ ^[0-9]+$ ]] || (( NUMBER_MONTHS_SAVES < 3 || NUMBER_MONTHS_SAVES > 6 )); then
    echo "Error: --months-saves must be an integer between 3 and 6 (got: '$NUMBER_MONTHS_SAVES')" >&2
    exit 1
fi

# --- Calculations ---
NEEDS=$(( MONTHLY_INCOME * 50 / 100 ))
WANTS=$(( MONTHLY_INCOME * 30 / 100 ))
SAVINGS=$(( MONTHLY_INCOME * 20 / 100 ))
EMERGENCY_FUND=$(( NEEDS * NUMBER_MONTHS_SAVES ))

OUTPUT="
====================================
50-30-20 Budget Summary
====================================
Monthly Income : \$$MONTHLY_INCOME

Needs   (50%)  : \$$NEEDS
Wants   (30%)  : \$$WANTS
Savings (20%)  : \$$SAVINGS

Emergency Fund : \$$EMERGENCY_FUND
(${NUMBER_MONTHS_SAVES} months × \$$NEEDS needs)
====================================
"

if [[ "$GENERATE_OUTPUT_FILE" == true ]]; then
    OUTPUT_FILE="$(pwd)/budget_$(date +%Y%m%d_%H%M%S).txt"
    echo "$OUTPUT" > "$OUTPUT_FILE"
    echo "Budget written to: $OUTPUT_FILE"
else
    echo "$OUTPUT"
fi
