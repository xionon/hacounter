vagrant ssh consul -c "sudo service consul restart"
vagrant ssh proxy -c "sudo service consul restart"
vagrant ssh redis -c "sudo service consul restart"
vagrant ssh app-0 -c "sudo service consul restart"
vagrant ssh app-1 -c "sudo service consul restart"
vagrant ssh app-2 -c "sudo service consul restart"