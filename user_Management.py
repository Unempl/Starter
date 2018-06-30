UserDict = {"AreLIN": {"age": "25", "phone": "110"},
            "Boy": {"age": "18", "phone": "120"},
            "Teacher": {"age": "18", "phone": "119"},
            "Studet": {"age": "20", "phone": "991"}
            }
action = input('please enter a word')
if action == 'delete':
    print(UserDict)
    delete_name = input('please enter a name to delete')
    if delete_name in UserDict:
        del UserDict[delete_name]
        print(UserDict)
    else:
        print('用户不存在')

elif action == 'update':
    update_info = input('用户名：年龄：联系方式')
    update_info = update_info.split(':')
    update_name = update_info[0]
    if update_name in UserDict:
        UserDict[update_name] = {'age':update_info[1],'phone':update_info[2]}
        print(UserDict[update_name])
    else:
        print('用户不存在')

elif action == 'find':
    username = input('用户名：')
    if username in UserDict:
        print(UserDict[username])
    else:
        print('用户不存在')

elif action == 'dict':
    print('用户名：年龄：联系方式')
    for user in UserDict:
        print('用户名：',user,'年龄：',UserDict[user]['age'],'联系方式：',UserDict[user]['phone'])

elif action == 'exit':
    exit('程序正在退出')

else:
    print('没有这个选项')
