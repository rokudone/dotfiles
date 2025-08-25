#!/bin/bash
# detect_mcp_nvim_step1.sh - Create detection buffers in each Neovim instance

current_dir=$(pwd)
echo "=== MCP Neovim Detection - Step 1 ==="
echo "Current directory: $current_dir"

# Get embedded Neovim PIDs in current directory
embed_pids=$(ps aux | grep -E "nvim.*--embed" | grep -v grep | awk '{print $2}' | while read pid; do
    if lsof -p $pid 2>/dev/null | grep -E "cwd.*DIR" | grep -q "$current_dir$"; then
        echo $pid
    fi
done)

count=$(echo "$embed_pids" | grep -v "^$" | wc -l)

if [ $count -eq 0 ]; then
    echo "ERROR: No embedded Neovim instances found in current directory"
    exit 1
fi

echo "Found $count instance(s). Creating detection buffers..."

# Create detection buffers
echo "$embed_pids" | while read pid; do
    # Find socket in multiple possible locations
    socket=""
    
    # Try to find socket from nvr --serverlist
    socket=$(nvr --serverlist | grep "${pid}\.0$" | head -1)
    
    # If not found, search in common temp directories
    if [ -z "$socket" ]; then
        socket=$(find /var/folders -name "nvim.${pid}.0" -type s 2>/dev/null | head -1)
    fi
    
    if [ -n "$socket" ]; then
        # Create new buffer with identification text
        nvr --servername "$socket" --remote-send ":enew<CR>i=== MCP Detection ===<CR>PID: $pid<CR>Socket: $socket<CR>Time: $(date)<CR><ESC>:set buftype=nofile<CR>:file MCP_Detection_${pid}<CR>"
        echo "✓ Created detection buffer in PID $pid"
        echo "  Socket: $socket"
    else
        echo "✗ Could not find socket for PID $pid"
    fi
done

echo ""
echo "→ Claude will now check which buffer opened in the IDE"