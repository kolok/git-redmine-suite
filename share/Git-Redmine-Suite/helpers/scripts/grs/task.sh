# tasks
function task_update
{
	declare -a PARAMS

	PARAMS+=(--task_id "$task")
	PARAMS+=(--status_ids "$status")
	PARAMS+=(--assigned_to_id "$assigned_to")

	declare -a ADD_PARAMS
	if [ "$status" = "$REDMINE_REVIEW_TODO" ]
		then
		ADD_PARAMS+=(--progress "100")
	elif [ -n "$progress" ]
		then
		ADD_PARAMS+=(--progress "$progress")
	fi

	if [ -n "$notes" ]
		then
		ADD_PARAMS+=(--notes "$notes")
	fi

	if [ -n "$cf_id" ] && [ -n "$cf_val" ]
		then
		ADD_PARAMS+=(--cf_id "$cf_id")
		ADD_PARAMS+=(--cf_val "$cf_val")
	fi

    redmine-update-task "${PARAMS[@]}" "${ADD_PARAMS[@]}"
    redmine-check-task "${PARAMS[@]}"
}

function task_start {
	TASK=$1
	if [ -z "$TASK" ]; then
		echo "Missing TASK_NUMBER : "
		echo ""
		HELP=1 $0
	fi

	if git config redmine.task.$TASK.branch; then
		task_continue "$1"
	else
		task_create "$1"
	fi

}

function task_continue {
	TASK=$1

}

function task_create {
	TASK=$1

	echo "Starting the task : "
	if ! redmine-get-task-info --task_id=$TASK --with-extended-status; then
		exit 1
	fi
	if ! ask_question --question="Do you really want to start this task ?"; then
		exit 1
	fi

	echo "Updating redmine status ..."

	task=$TASK \
	status=$REDMINE_TASK_IN_PROGRESS \
	assigned_to=$REDMINE_USER_ID \
	cf_id=$REDMINE_GIT_REPOS_ID \
	cf_val=$REDMINE_GIT_REPOS_URL \
	progress=10 \
	task_update

	#TASK_TITLE=$(redmine_get_title $TASK)
	#SLUG_TITLE=$(/usr/local/share/Git-Redmine-Suite/helpers/slug --this "$TASK_TITLE")
	#BRNAME="redmine-$SLUG_TITLE"


}