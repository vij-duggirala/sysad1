#!/bin/bash

#current directory is /root 

#Adding users with corresponding ids and passwords
useradd -m MasterH
(echo "master"; echo "master") | passwd MasterH
useradd -m Heisenberg
(echo "hei"; echo "hei") | passwd Heisenberg
useradd -m Hertz
(echo "hertz"; echo "hertz") | passwd Hertz
useradd -m Holland
(echo "holland"; echo "holland") | passwd Holland

for i in {1..20}
do
	useradd -m Heisenberg$i
	(echo "hei$i"; echo "hei$i") | passwd Heisenberg$i
	useradd -m Hertz$i	
	(echo "hertz$i"; echo "hertz$i") | passwd Hertz$i
	useradd -m Holland$i
	(echo "holland$i"; echo "holland$i") | passwd Holland$i
done

#giving MasterH rwx permissions on all scientists recursively
setfacl -R --mask -m u:MasterH:rwx /home/Heisenberg
setfacl -R --mask -m u:MasterH:rwx /home/Hertz
setfacl -R --mask -m u:MasterH:rwx /home/Holland

#giving MasterH and corresponding scientists rwx permissions on their corresponding interns recursively
for i in {1..20}
do	
	setfacl -R --mask -m u:Heisenberg:rwx /home/Heisenberg$i
	setfacl -R --mask -m u:MasterH:rwx /home/Heisenberg$1

	setfacl -R --mask -m u:MasterH:rwx /home/Hertz$i
	setfacl -R --mask  u:Hertz:rwx /home/Hertz$i
	setfacl -R --mask -m u:MasterH:rwx /home/Holland$i
	setfacl -R --mask u:Holland:rwx /home/Holland$i
done


#creating task folders for scientists
for i in {1..5}
do
	
		mkdir /home/Heisenberg/task$i
		
		mkdir /home/Holland/task$i
		

		mkdir /home/Hertz/task$i

	
done

#creating task folders for all interns, owner is root , and interns by default don't have write permission so they won't be able to delete the files inside the corresponding directory nor will they be able to execute any file
for i in {1..20}
do 
	for j in {1..5}
	do
		mkdir /home/Heisenberg$i/task$j
		#changing mask to r, such that effective permissions on scientists and MasterH become read only, and thus files inside this directory are not deletable by anyone
		setfacl -m m::r /home/Heisenberg$i/task$j
		mkdir /home/Holland$i/task$j
		setfacl -m m::r /home/Holland$i/task$j
		mkdir /home/Hertz$i/task$j
		setfacl -m m::r /home/Hertz$i/task$j
		done
done


#for scientist task folders, create 50 text files and fill with 128 random characteristics
for i in {1..5}
do
	for j in {1..50}
	do
		(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*_+-' | head -c 128 ) > /home/Heisenberg/task$i/Heisenberg_task$j.txt
		(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*_+-' | head -c 128 ) > /home/Hertz/task$i/Hertz_task$j.txt
		(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*_+-' | head -c 128 ) > /home/Holland/task$i/Holland_task$j.txt
	done
done


#create a script file, storing the commands to be executed at 23:59
cd /home
touch file.sh
#changing the permissions such that owner can execute it
chmod 511 /home/file.sh


#getting a random sequence of 5 numbers from the list of 1-50 and assigning corresponding taskfiles to interns
echo "#!/bin/bash
for i in {1..20}; 
do
	 for j in {1..5}
	 do
		 for k in \$(shuf -n 5 -i 1-50)
		 do
			 cp /home/Heisenberg/task\$j/Heisenberg_task\$k.txt /home/Heisenberg\$i/task\$j/\$k.txt
			 cp /home/Hertz/task\$j/Hertz_task\$k.txt /home/Hertz\$i/task\$j/\$k.txt
			 cp /home/Holland/task\$j/Holland_task\$k.txt /home/Holland\$i/task\$j/\$k.txt
		 done
	 done
done" > /home/file.sh


#every day at 23:59, the script 'file' is executed
job="59 23 * * * /home/file.sh"
(echo "$job") | crontab -
		


