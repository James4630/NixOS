if ps aux | grep "[s]oularr.py" > /dev/null; then
	echo "Soularr is already running. Exiting..."
else
	#rm -rf /mnt/storage/slskd/downloads/*
	#rm -rf /mnt/storage/slskd/incomplete/*
	nix-shell /home/james/system-config/pkgs/soularr --run 'python /home/james/system-config/pkgs/soularr/soularr.py'
fi
