
echo -n "nova" > /proc/self/comm 2>/dev/null

VERSION="1.1.2"

REPO_RAW="https://raw.githubusercontent.com/Ekith/nova/release"
BIN_DIR="$HOME/.local/bin"
COMPLETION_DIR="$HOME/.local/share/bash-completion/completions"

case "${1:-}" in
    --help|-h)
        echo "Usage: nova <commande_à_lancer>"
        echo ""
        echo "Options:"
        echo "  -h, --help               Affiche cette aide"
        echo "  -v, --version            Affiche la version installée"
        echo "  -u, --upgrade            Met à jour nova vers la dernière release"
        echo "  -i, --install <version>  Installe une version précise de nova"
        echo "      --uninstall          Désinstalle nova"
        echo ""
        echo "Signaux (depuis un autre terminal, PID affiché au démarrage):"
        echo "  kill -USR1 <pid>         Redémarre le processus"
        echo "  kill -INT <pid>          Redémarre le processus (nova au premier plan uniquement)"
        echo "  kill <pid>               Arrête nova et le processus lancé"
        exit 0
        ;;
    --upgrade|-u)
        echo "Upgrading nova..."
        curl -fsSL "$REPO_RAW/install.sh" | bash
        exit $?
        ;;
    --install|-i)
        version="${2:-}"
        if [ -z "$version" ]; then
            echo "Usage: nova --install <version>" >&2
            exit 1
        fi
        curl -fsSL "$REPO_RAW/install.sh" | bash -s -- "$version"
        exit $?
        ;;
    --uninstall)
        read -r -p "Désinstaller nova (supprime $BIN_DIR/nova et sa complétion) ? [y/N] " confirm
        case "$confirm" in
            [Yy]|[Yy][Ee][Ss]) ;;
            *) echo "Annulé."; exit 0 ;;
        esac
        echo "Uninstalling nova..."
        rm -f "$BIN_DIR/nova"
        rm -f "$COMPLETION_DIR/nova"
        echo "nova uninstalled."
        exit 0
        ;;
    --version|-v)
        echo "nova version $VERSION"
        exit 0
        ;;
esac

if [ $# -eq 0 ]; then
    echo "Usage: nova <commande_à_lancer>"
    exit 1
fi


# Get all arguments passed to the script
echo "Arguments passed to the script: $*"

# Keep the command as an array so arguments with spaces/quotes survive
cmd=("$@")

is_run=true

echo_information_keybind() {
    echo "Nova running (PID: $$)."
    echo "Press [K] to stop nova."
    echo "Press [C] to clear the console."
    echo "Press [N] to clean up the process (kill and restart)."
    echo "Press [R] or [Ctrl+C] to restart the process."
    echo "Send SIGUSR1 (kill -USR1 $$) to restart the process from another terminal."
}

# Function to launch the process
launch_process() {
    echo ""
    echo ""
    echo "Launching process..."
    "${cmd[@]}" &
    process_pid=$!
    echo "Process started with PID: $process_pid"
    echo_information_keybind
}

get_all_pids() {
    local pid=$1
    local children
    children=$(pgrep -P "$pid")
    echo "$pid"
    for child in $children; do
        get_all_pids "$child"
    done
}

kill_process() {
    if ! kill -0 "$process_pid" 2>/dev/null; then
        return
    fi

    echo "Killing process with PID: $process_pid"

    pids=$(get_all_pids "$process_pid")

    kill -TERM $pids 2>/dev/null

    for _ in 1 2 3 4 5; do
        alive=""
        for p in $pids; do
            kill -0 "$p" 2>/dev/null && alive="$alive $p"
        done
        [ -z "$alive" ] && return
        sleep 0.2
    done

    echo "Force killing remaining process(es):$alive"
    kill -KILL $alive 2>/dev/null
}

clean_up() {
    kill_process
    clear
    echo "Process has stopped. Restarting..."
    launch_process
}

# Run the action requested by a key press or a signal
handle_action() {
    case "$1" in
        restart)
            kill_process
            echo "Process has stopped. Restarting..."
            launch_process
            ;;
        stop)
            kill $$
            ;;
        clear)
            clear
            ;;
        clean)
            clean_up
            ;;
    esac
}

# Signals only record the requested action, the main loop runs it.
# This avoids nesting actions when a signal arrives mid-action.
pending_action=""
trap 'pending_action=restart' SIGINT SIGUSR1

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
    # Keys use their own variable so they never overwrite a signal action
    key_action=""
    if read -t 1 -n 1 key ; then
        case "$key" in
            [Rr]) key_action=restart ;;
            [Kk]) key_action=stop ;;
            [Cc]) key_action=clear ;;
            [Nn]) key_action=clean ;;
        esac
        key=""
    fi
    if [ -n "$pending_action" ]; then
        # Bash runs traps between commands: reading and clearing in a
        # single command ensures no signal is lost in between
        action=$pending_action pending_action=""
        handle_action "$action"
    fi
    if [ -n "$key_action" ]; then
        handle_action "$key_action"
    fi
done
