function dfs
    switch $argv[1]
    case mount
        sshfs -o cache=yes -o compression=no -o kernel_cache $DFS_HOST_INT:$argv[2] ~/$argv[2]
    case rmount
        sshfs -o cache=yes -o compression=yes -o kernel_cache $DFS_HOST:$argv[2] ~/$argv[2]
    case umount
        fusermount -u $argv[2]
    case '*'
        echo "Invalid action"
    end
end