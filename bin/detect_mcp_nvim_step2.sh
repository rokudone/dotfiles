#!/bin/bash
# detect_mcp_nvim_step2.sh - Cleanup detection buffers

current_dir=$(pwd)
echo "=== MCP Neovim Detection - Step 2 (Cleanup) ==="

# Get embedded Neovim PIDs in current directory
embed_pids=$(ps aux | grep -E "nvim.*--embed" | grep -v grep | awk '{print $2}' | while read pid; do
    if lsof -p $pid 2>/dev/null | grep -E "cwd.*DIR" | grep -q "$current_dir$"; then
        echo $pid
    fi
done)

# Cleanup detection buffers
echo "$embed_pids" | while read pid; do
    socket=$(nvr --serverlist | grep "${pid}\.0$")
    
    if [ -n "$socket" ]; then
        # Create new empty buffer before closing detection buffer to prevent unwanted file opening
        nvr --servername "$socket" --remote-send ":enew<CR>" 2>/dev/null
        # Close detection buffer
        nvr --servername "$socket" --remote-send ":bdelete MCP_Detection_${pid}<CR>" 2>/dev/null
        echo "✓ Cleaned up detection buffer in PID $pid"
    fi
done

echo ""
echo "Cleanup complete!"