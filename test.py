import os

ip = input("IP to check: ")
os.system('ping -n 4 {}'.format(ip))

