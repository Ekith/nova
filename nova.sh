


REPO_RAW="https://raw.githubusercontent.com/Ekith/nova/main"
BIN_DIR="$HOME/.local/bin"
COMPLETION_DIR="$HOME/.local/share/bash-completion/completions"

case "${1:-}" in
    --upgrade|-u)
        echo "Upgrading nova..."
        curl -fsSL "$REPO_RAW/nova.sh" -o "$BIN_DIR/nova"
        chmod +x "$BIN_DIR/nova"
        curl -fsSL "$REPO_RAW/nova_completion.bash" -o "$COMPLETION_DIR/nova"
        echo "nova upgraded."
        exit 0
        ;;
    --uninstall)
        echo "Uninstalling nova..."
        rm -f "$BIN_DIR/nova"
        rm -f "$COMPLETION_DIR/nova"
        echo "nova uninstalled."
        exit 0
        ;;
esac

if [ $# -eq 0 ]; then
    echo "Usage: $0 <command_to_run>"
    exit 1
fi


# Get all arguments passed to the script
args="$@"

echo "Arguments passed to the script: $args"


# Build th command to run the process with the passed arguments
command="$args"

reloader_id=$$

is_run=true

echo_information_keybind() {
    echo "Nova running (PID: $$)."
    echo "Press [K] to stop nova."
    echo "Press [C] to clear the console."
    echo "Press [N] to clean up the process (kill and restart)."
    echo "Press [R] to restart the process."
}

# Function to launch the process
launch_process() {
    echo ""
    echo ""
    echo "Launching process..."
    $command &
    process_pid=$!
    echo "Process started with PID: $process_pid"
    echo_information_keybind
}

kill_process() {
    echo "Killing process with PID: $process_pid"
    kill $process_pid
}

clean_up() {
    kill_process
    clear
    echo "Process has stopped. Restarting..."
    launch_process
}

# Handle ctrl+c to kill the process
trap "kill_process" SIGINT

# Handle script exit to kill the process
trap "kill_process" EXIT




# Launch process and get its PID
launch_process


while $is_run; do
    # Check if the process is still running
    if ! kill -0 $process_pid 2>/dev/null; then
        echo "Process has stopped. Restarting..."
        launch_process
    fi
    if read -t 1 -n 1 key ; then
        case "$key" in
            [Rr]) # Restart
                kill_process
                echo "Process has stopped. Restarting..."
                launch_process
                ;;
            [Kk]) # Kill
                kill $$
                ;;
            [Cc]) # Clear
                clear
                ;;
            [Nn]) # New
                clean_up
                ;;
        esac
        key=""
    fi
done
