# ~/.config/zsh/zsh-functions.zsh

# Function to open a project in Neovim inside a new tmux window, setting the window name to 'nvim' and project name

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

    # Define the window name combining 'nvim' and the project name
    local window_name="nvim - ${project_name}"

    # Create a new tmux window with the window name and open nvim in that directory
    if [ -n "$TMUX" ]; then
        # We are already inside a tmux session
        tmux new-window -n "$window_name" "cd $project_path && nvim ."
        #tmux new-window -n "$window_name" "cd $project_path && nvim ."
        # Set iTerm2 tab name
        printf "\033]0;%s\007" "$window_name"
    else
        # Not inside a tmux session, so start tmux and create a new window
        tmux new-session -d -s "$project_name" -c "$project_path"
        tmux send-keys -t "$project_name:$window_name" 'nvim .' C-m
        tmux attach-session -t "$project_name"
        # Set iTerm2 tab name
        printf "\033]0;%s\007" "$window_name"
    fi
}
