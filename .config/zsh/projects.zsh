proj() {
    local project_dir="$HOME/Documents/Projects"

    # Use fzf to select a project if no argument provided, or use the provided argument
    if [ -z "$1" ]; then
        # No argument provided, use fzf to select a project directory
        local project_name=$(find "$project_dir" -maxdepth 1 -type d | sed "s|${project_dir}/||" | fzf --height=40% --reverse)

        # Check if a project was selected
        if [ -z "$project_name" ]; then
            echo "No project selected."
            return 1
        fi
    else
        # Argument provided, use it as the project name
        local project_name="$1"
    fi

    # Check if the project directory exists
    local project_path="${project_dir}/${project_name}"
    if [ ! -d "$project_path" ]; then
        echo "Project directory not found: $project_path"
        return 1
    fi

    # Generate a unique session name using the project name
    local session_name="${project_name}"
    echo "Opening project: $project_name"

    # Check if we're already inside a tmux session
    if [ -n "$TMUX" ]; then
        # We're inside a tmux session
        # Create a new session without attaching to it
        tmux new-session -d -s "$session_name" -c "$project_path"
        # Set up the initial window
        tmux send-keys -t "$session_name" "cd $project_path && nvim ." C-m
        # Switch to the new session
        tmux switch-client -t "$session_name"
    else
        # We're not inside a tmux session
        # Create a new session and attach to it
        tmux new-session -s "$session_name" -c "$project_path" "nvim ."
    fi

    # Set iTerm2 tab name
    printf "\033]0;%s\007" "nvim $session_name"
}
