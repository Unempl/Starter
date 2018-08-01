## Ext文件系统

文件在分区里面组织方法和数据结构

windows：fat32、ntfs

linux：ext2【3，4】、xfs

```shell
inode：存放文件的元数据metadata【stat FILEPATH查看文件元数据】【ls -i】
block：用于存放数据的基本单位（文件的实际数据）
superblock：存放文件系统的整体信息（备份）【dumpe2fs /dev/sda1】

superblock、group description table、data block bitmap、inode bitmap、inode table、block table

存放数据（指针）：		
		查看inode bitmap（空闲）申请存放元数据
		
		查看data block bitmap（空闲）存放实际数据（占用n个block）

目录下的block有什么数据：# 创建新的文件同时会创建新的entry
		block：entry：文件->inode【test->inode4724】
		
链接：
		软连接：symbolic link【ln -s SOURCE DEST】【新的inode新的block指向文件，删除文件有影响】【可以跨文件系统 | 可以对目录和文件做】
		硬链接：【ln SOURCE DEST】只占entry的空间【指向同一个inode，删除文件无影响】【不可以跨文件系统 | 不能对目录做】
		
1.block是否越大越好？视情况而定
2.目录下的block有什么数据
3.目录的大小都是block的倍数
4.为什么/目录和/boot目录inode一样？不同分区（sda1）
5.磁盘空间不足的原因：data block用尽 | inode用尽（每个文件有且只有一个inode）
6.一个文件系统（分区）能够创建的文件总数与inode数量有关
7.创建、移动、删除、复制文件对inode和block的影响：
			移动：（cp+rm）【同一个文件系统】entry的移动 |【不同文件系统】申请空闲的inode和block、复制源数据到新block、目录添加新的entry、删除源文件过程
			删除：硬链接数为1 【inode和block被置空，删除目录下文件的entry】| 硬链接数>1【硬链接数-1并删除目录下文件的entry】
			复制：申请空闲的inode，根据源文件需要的block数，向目标文件系统申请空闲的block，将源block数据复制到新block中，向目标目录所在的block里写入文件entry
8.硬链接为何不能对目录做

文件粉碎：shred
```

## 文件系统管理

https://jingyan.baidu.com/article/c910274bc41709cd361d2d0e.html

https://www.cnblogs.com/kaishirenshi/p/7850247.html

创建一个文件系统步骤：

​	1.查看当前硬盘可用的空间 fdisk -l /dev/sda[b,c,d]

​	2.分区：fdisk -cu /dev/sda【parted】【m查看帮助】

**![img](https://imgsa.baidu.com/exp/pic/item/a6aed01b9d16fdfab984aa9db68f8c5495ee7b9d.jpg)**

​	3.重读分区表/重启【partx -a /dev/sda】

​	4.制作文件系统（格式化）mkfs -t ext4 /dev/sda5{6,7}【主分区否需格式化】| mkfs.ext4 /dev/sda5

​	5.创建mount point【mkdir /mnt/disk{1,2,3}】并挂载【mount -t ext4 /dev/sda5 /mnt/disk1】| 检查挂载信息【df -TH】

​	6.写入fstab【dev/sda5	/mnt/disk1	ext4	defaults		0	0】

### 挂载

mount [option] Device Dir【umount /mnt/disk1前提：文件系统不能被其他进程占用】

option：

​	 -t FS_TYPE 

​	 -o 文件系统挂载选项：

​		【-a(mount -a 默认自动挂载) | sync\async【同步数据{不容易丢失cpu繁忙}\异步】| ro\rw | defaults默认挂载选项】

​		其他挂载选项：loop：用于挂载本地的文件到本地目录iso镜像文件【mount -t iso9660 -o loop 】 | remount修改挂载 选项【mount -o remount,rw /mnt/disk1】

### fstab格式

https://wiki.archlinux.org/index.php/Fstab_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)

```shell
 <file system>        <dir挂载点>         <type>    <options>             <dump是否备份> <pass是否fsck文件系统检查>
 filesystem：/dev/sda5 | LABEL=game e2label /dev/sda5 game(一般不用) | UUID= blkid /dev/sda5（唯一性）
UUID=4918ec6e-8808-40dc-a808-3cb3d4280259 /                       ext4    defaults        1 1【1优先级最高】
UUID=9c944b2f-9259-4835-8c5f-77fe184bf893 /boot                   ext4    defaults        1 2
UUID=900d1d75-51fe-4be1-9f50-aac0e96aaa91 swap                    swap    defaults        0 0

```



### swap分区

**一、新建磁盘分区作为swap分区**
1.以root身份进入控制台（登录系统），输入
\# swapoff -a #停止所有的swap分区

\2. 用fdisk命令（例：# fdisk /dev/sdb）对磁盘进行分区，添加swap分区，新建分区，在fdisk中用“t”命令将新添的分区id改为82（Linux swap类型），最后用w将操作实际写入硬盘（没用w之前的操作是无效的）。

\3. # mkswap /dev/sdb2 #格式化swap分区，这里的sdb2要看您加完后p命令显示的实际分区设备名

\4. # swapon /dev/sdb2 #启动新的swap分区

\5. 为了让系统启动时能自动启用这个交换分区，可以编辑/etc/fstab,加入下面一行
/dev/sdb2 swap swap defaults 0 0
**二、用文件作为Swap分区**

1.创建要作为swap分区的文件:增加1GB大小的交换分区，则命令写法如下，其中的count等于想要的块的数量（bs*count=文件大小）。
\# dd if=/dev/zero of=/root/swapfile bs=1M count=1024

2.格式化为交换分区文件:
\# mkswap /root/swapfile #建立swap的文件系统

3.启用交换分区文件:
\# swapon /root/swapfile #启用swap文件

4.使系统开机时自启用，在文件/etc/fstab中添加一行：
/root/swapfile swap swap defaults 0 0



------------------------------------

mkfs.ext4 /dev/sdb5{6,7,8}

mkdir /mnt/disk1/p{1,2,3,4,5}

vi /etc/fstab

mount 【mount -a】

-----------------------------------------------------

parted /dev/sdc

mkfs.ext4 /dev/sdc{1,2,3,4}

mkdir /mnt/disk2/p{1,2,3,4,5}

vi /etc/fstab

mount【mount -a】

----------------------------------

lftp 

mirror 拷贝目录

mount -t iso9660 -o loop /mnt/disk1/p1/test/test.iso /mnt/testdir/【df】

-----------------

ln -s /mnt/testdir/ /tmp/testdir【软链接文件自动生成 | 非目录】

ln /mnt/disk1/p1/test/test.iso /mnt/disk1/p1/test.zip

rm test.iso

cd /mnt/testdir/【ls】【可以访问】

## 编辑器

- nano
- vi\vim
  - 命令模式
    - 移动光标【h←j↓k↑l→】【gg光标移动到首行】【G末行】【NG | Ngg】【w 按单词向后.跳转| W 按单词向后跳转blank| b 按单词向前跳转| B 按空格向前跳转 | e 跳转单词末字符| E 按空格跳转到单词末字符】【0 跳转到当前行绝对行首/^ 跳转到当前行第一个非空字符】【$ 跳转到行末】
      - 数字+操作命令+光标移动=执行多少次移动命令
    - 内容操作
      - 复制yank【y：5yw | 5yl】【yy复制当前行：5yy】
      - 剪切delete【d：d0 | d$ | 5dw】【dd删除当前行：5dd】【x删除当前字符】
      - 粘贴paste【p | P】
      - 撤销undo【u】【反撤销ctrl + r】
    - 其他模式入口
      - 进入编辑模式
        - a【after】
        - A【行末进入】
        - i
        - I【行首进入】
        - o【向下另起一行】
        - O【向上另起一行】
      - 进入选择模式（visual）
        - v【进入普通的选择模式】
        - V【整行选择模式】
        - ctrl + v【块选择】
      - 进入替换模式replace
        - r【单次替换】
        - R【进入替换模式】
      - 进入窗口模式
        - ctrl + w，s【比较文件不同】
      - 进入末行模式
        - ​
  - 编辑模式
  - 末行模式
    - 对文件操作 :【打开新的文件】e FILENAME| :x | ZZ【保存退出】| ZQ【不保存退出】| /STRING | n下一个 |【另存为】:w FILEPATH【:5,10w】|【%】1,3:s/OLD/NEW/FLAG【替换1,3行】| :X【加密】
    - 搜索功能
    - 选项设置 :set all查看所有【set autoindent】【set ignorecase】【永久生效：创建~/.vimrc把选项写进去】
  - 选择模式
  - 替换模式
  - 窗口模式
- emacs



esc + . 调用上次命令的参数（路径）

----------------------



vi ~./vimrc

58gg

40l	/dir/bin/foo

gg

/bzip2 #137

:50,100s/man/MAN/gc	#1

u

65gg --V --向下73 --y --G --p	【8yj】

:21,42s/^#//【^：以#开头】 

:w man.test.config

27gg --V --d --15dl 	【15x】#i

gg --O --i'm a student...



http://www.cnblogs.com/xiaojiang1025/archive/2016/09/09/5856741.html

https://blog.csdn.net/derkampf/article/details/52080396

## 用户管理

###用户

linux使用用户作为管理系统身份

- linux为每个用户分配唯一uid：【root】uid=0 | 【普通用户】uid>=500 | 【系统用户】0<uid<500
- 相关属性：
  - UID
  - GID（基本组，only one）
  - GIDs（附加组，etc...）
- 用户配置文件：/etc/passwd【用户邮箱：/var/spool/mail】
  - root：x：0:0:root:/root:/bin/bash
  - 用户名:x :UID:GID:描述:家目录:bash
- 用户管理相关命令：
  - 创建：useradd [option] -u【UID】| -g【GID】| -G【GIDs】| -d【DIR】 | -s【SHELL】【/sbin/nologin不能登陆】
  - 删除：userdel：【userdel -r USERNAME】
  - 修改：usermod：与创建同
  - 查询：id USERNAME

###组

将多个用户划分到一个组进行管理，便于对组统一分配权限，--**创建用户时，会自动创建与用户名同名的组**--

- linux为组分配GID：【root】GID=0 | 【普通用户】| 【系统用户】
- 组分类：
  - 基本组：用户属性中的GID
  - 附加组：用户属性中的GIDs
- 组配置文件：/etc/group
  - 组名:x :GID:组成员
- 相关命令：
  - 创建：groupadd 	GROUPNAME
  - 删除：groupdel   GROUPNAME



###密码

/etc/shadow

密码管理：

- passwd [USERNAME]
- echo "PASSWORD" | passwd --stdin USERNAME（无交互式修改密码）

### 权限

限制用户对资源访问	【ls -l	-rw-（拥有者）r--（所属组）r--（其他人）】	进程--------(携带用户信息UID、GID、GIDs)------->资源

用户相对资源有三种访问者类型：

- 进程uid=资源uid，用户是资源的拥有者
- 进程gid，gids=资源gid，组是资源的所属组
- 都不匹配，用户是资源的其他人

基本权限：

- r，可读【可以查看目录内容、可以进入目录】
- w，可写【可以重命名文件、增删目录文件】【entry】
- x，可执行（命令、脚本）【目录可执行权限t、cd、cp、mv、rm】

相关命令：

- chown修改拥有组或所属组	chown [-R]递归	【chown [-R] USER[:GROUP] FILE】

- chgrp修改所属组【同上（只对组）】

- chmod修改权限：
  - 符号表示		chmod a | i | o | g  +[-=覆盖]  rwx【e.g.	chmod ug+w FILE】
     数字表示		chmod 664 FILE----->rw-rw-r--

- 权限掩码：控制用户在创建文件或目录时默认权限

  - umask

    - 【root】022 --- -w- -w-：
      - 创建文件时默认权限：【**初始权限-掩码权限**】初始权限：rw-rw-rw- | 掩码权限：--- -w- -w- | 结果：644
      - 创建目录时默认权限：【初始权限-掩码权限】初始权限：777 | 掩码权限：022 | 结果：rwxr-xr-x 755

  - 特殊权限：

    - suid（只能对可执行文件做）以文件拥有者权限执行文件【-rwsr-xr-x. 1 root root 30768 Nov 24  2015 /usr/bin/passwd】
    - sgid（对目录和可执行文件都可以做）目录下文件创建时自动继承目录组| 临时以文件所属组权限执行文件
    - sbit（只能对目录做）粘贴位sticky-bit【其他人不能删除文件】

    修改特殊权限chmod o+s FILENAME

  - 扩展权限：ACL（access control list）对特定用户定制权限

    - getfacl FILE
    - setfacl -m u:USER:PERMITTION /devops
    - setfacl -x u:USERNAME FILE删除权限
    - setfacl -b filename    删除文件上的权限列表


```shell
[root@aclhost mnt]# ls -l file

-rw-r--r--. 1 root root 0 Nov  7 09:14 file

如果此位为“.”,代表这位上没有扩展权限

如果此位为“+”,代表扩展权限存在

```

----

useradd mary -G admin

useradd alice -G admin

useradd bobby -s /sbin/nologin

echo "redhat" | passwd --stdin mary{alice,bobby}

mkdir -p /common/admin

cd /common/admin

chgrp admin admin/

chmod g+w admin/

chmod o-rx admin/

chmod g+s admin/

umask 0003

cp /etc/fstab /var/tmp

cd /var/tmp

chown alice fstab

chgrp admin fstab

chmod o-r fstab

getfacl fstab

setfacl -m u:mary:rwx fstab

setfacl -m u:bobby:r-x fstab

getfacl fstab



## BASH

### SHELL

能够解释用户输入的命令的命令解释器（echo $SHELL）

基本功能

- **shell执行命令过程**：

  - 从终端或shell脚本或-c读取输入
  - 按引用规则将输入分解成单词或运算符：转义字符 echo \\*和echo *| 单引号 echo '\*  $SHELL'完全转移 | 双引号 !部分转移
  - 将符号解析为简单或复杂的命令 cat /etc/fstab | wc -l【处理上一个命令的内容】
  - 进行各种shell扩展
    - 大括号	echo abc{1,2,3}===> echo abc1 abc2 abc3
    	 波浪号	ls $HOME变量的值 | 访问别人的家目录~USER | ~+当前目录 | ~-上一次访问的目录
    	 参数和变量	参数扩展${STR}	number=24 echo \${number}people
    	 命令替换		echo $(id root)	echo \`id root`
    	 算术扩展		$((EXPRESSION))	将运算结果输出
    	 进程替换		重定向 > | < | << | >>
    	 单词拆分		以$IFS拆分
    	 文件名扩展	* | ? | []		【通配符】
    - 引用去除

- 重定向【标准输入0 <| 出1 >| 错误输出2 2>】

  - 进程运行时关联三个文件描述符（/dev/fd/0,1,2）

  - STDIN【cat < /etc/fstab】

  - STDOUT

  - STDERR【ls /tmp /tmp2 > /dev/null】【ls /tmp /tmp2 &> tmp.txt | 2>&1】

  - CMD &> FILE | CMD > FILE 2>&1【ls /etc/fstab > /dev/pts/1】

  - \>>追加内容到

  - 即插即用文本：CMD > test.txt <<END无交互式生成文件【cat】

  - $? 命令的状态返回值 | 0成功 | 非0失败

  - ```shell
    # /bin/bash
    ping -c1 10.1.1.254 > /dev/null 2>&1
    if[$? -eq 0];then
    	echo "host is alive"
    else
    	echo "host is dead"
    fi
    ```

- 命令队列

  - &&      CMD1成功才执行CMD2
  - ||【CMD1 || CMD2     命令1返回值为非0即失败才执行命令2】
  - ;命令分隔符     mkdir ; mount -t
  - &将命令放入后台执行

- 管道【wc统计】【grep正则过滤】

  - CMD1 | CMD2 将命令1的输出作为命令2的输入
  - 2>&1【需要先将标准错误输出信息标准输出】【只能将标准输出信息，不能输出标准错误信息】

- 变量：VARNAME=VAR

  - 全局：在当前shell及其子shell生效【pstree】【export VARNAME】
  - 局部：仅在当前shell生效

- [等待命令结束，并收集结束状态]



### Bash特性

- 命令行编辑

  - 编辑命令行ctrl + b(efore)/ctrl + f(arward)
  - ctrl + l 清屏
  - ctrl + d 登出 | 输入终止符
  - ctrl + z 将前台进程放到后台

- 命令历史history 【echo $HISTSIZE】【环境变量\$HISTFILESIZE | \$HISTSIZE | \$HISTTIMEFORMAT】

  - !!执行上一条命令【!N执行编号为N的命令】【!-N执行倒数第N行】【!NAME执行最近一条以NAME开头的命令】
  - ctrl + r 搜索命令 Tab键入bash可修改

- 命令别名alias NEWNAME=OLDNAME

- 作业控制（进程）

- 登陆过程

  - /etc/profile
  - ~/.bash_profile
  - ~/.bashrc
  - /etc/bashrc

- 非登陆过程

  - ~/.bashrc【当前用户的配置】
  - /etc/bashrc【应用到所有人的配置】

- 正则表达式

  - grep 匹配PATTERN并打印匹配到的行

  - grep [option] "PATTERN" [FILE]

  - 选项【--color=auto高亮匹配】【-o只显示匹配到的内容】【-E支持扩展的元字符】【-i ignorecase】【-v 反向选择 | 显示没有匹配的行】【-f FILE使用文件中的正则来匹配】【-A N 匹配后N行 | -B N 匹配前N行 | -C N 匹配前后N行】【-P Perl】

  - PATTERN 正则表达式 由普通字符+元字符，用于匹配特定字符串

  - 元字符（扩展加上-E选项）：. 匹配单个任意字符 | \*【任意次】【.*任意个任意字符】  ?【<=1次】  +【>=1次】  {n,m}【n到m次】 【限定次数】| () 将括号内的内容看作整体【(123){2,}123两次以上】或分组\1 \2| \\> 单词右边界 \\<单词左边界【位置锚定】

  - \b边界   \d数字   \w英文字符（数字、字母、下划线）   \s空白字符    \S非空白字符   \D非数字

    - 匹配空白行 grep "^\$" FILE
    - grep "^#\s+\S"===="^#[[:blank:]]+[^[:blank:]]"

  - ^x以x开头

  - x\$以x结尾

  - '^([0-9])(.\*)\2\1\$'====>1aa1 | 1aaaa1 etc..

  - '\\\<the\\>'

  - 5.\*5

  - 5?5

  - 5+5

  - ```shell
    5?5
    5655
    alias grep='grep --color=auto'
    ```

  - ```shell
    1.cat /proc/meminfo | egrep -o "^[sS].*"	cat /proc/meminfo | egrep -o "^s|^S.*"	cat /proc/meminfo | egrep -o "^(s|S).*"
    2.grep -E '^root|^centos|^user1' /etc/passwd
    3.cat /etc/rc.d/init.d/functions | egrep "\b[a-z]+\b\(\)"
    4.echo "/etc/sysconfig/network-scripts/ifcfg-eth0" | grep '/.*'==============>>grep -o -E '[^/]+$'【非斜杠多个结尾】
    	【dirname】		grep '/.*/'
    1.grep匹配ip
    https://www.cnblogs.com/olive987/p/5844501.html
    X.X.X.X
    (X.){3}X
    1-254
    一位数：\b[0-9]\b
    二位数：\b[1-9][0-9]\b
    三位数：\b1[0-9][0-9]\b
    			\b2[0-4][0-9]\b
    			\b25[0-4]
    2.grep -P '^\b(\w)+\b.*\1$'零宽断言
    3.ifconfig eth0 | grep -E -o "inet addr:[0-9.]+"

    ```

###常用文本处理命令

- grep
- cat【FILENAME】
- tail【 | tail -N】
- head【 | head -N】
- sort排序【默认ascii排序】
  - options
  - -t【指定字段分隔符】
  - -k【指定字段数】
  - -n【以数字大小排序】
  - -r 逆序（从大到小）
  - -u 去重
  - sort -t: -k3 -n -r /etc/passwd【cut -d: -f7 /etc/passwd | sort -u】【】
- cut从文件的每一行中截取部分内容：cut [options] FILE
  - [OPTION]
  - -c【字符范围】
  - -d【指定字段分隔符】
  - -f【指定字段数】
  - cut -d: -f1 /etc/passwd【-d' ' -d'\$'】
- uniq
  - -c 去重【去重前先排序】【sort | uniq -c | awk '{print \$2}'】
- wc统计行数、单词数、字节数、字符数
  - -l【行数】
  - -w【单词数】
  - -c【字节数】
  - -m【字符数】
  - grep 'bash\$' | wc -l



```shell
1.grep -P "((25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))\.){3}(25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))" ifcfg-eth0 | cut -d= -f2 > FILE
ipaddr=`cat FILE`
export ipaddr
echo $ipaddr
# export ipaddr=`ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | cut -d' ' -f1`

2.cut -d: -f3 /etc/group | sort -n > ~/gid.txt | wc -l
# sort -t: -k3 -n /etc/group | tee ~/gid.txt | wc -l
3.netstat -tulnp | grep 22
# netstat -ant | grep -P "\b22\b"
1.grep -P -o "^((25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))\.){3}(25[0-5]|2[0-4]\d|((1\d{2})|([1-9]?\d)))" access.log | sort -n | awk '{a[$1]+=1;}END{for(i in a){print a[i]" " i;}}' | sort -n -r | head -3
# cut -d'-' -f1 access.log | sort | uniq -c | sort -n -r | head -3 | awk '{print $2}'
2.grep -o -E '(GET|POST)' access.log | sort | awk '{a[$1]+=1;}END{for(i in a){print a[i]" " i;}}'
# cut -d'"' -f2 access.log | cut -d' ' -f1 | sort | uniq -c | sort -rn
3.cut -d\" -f2 access.log | cut -d' ' -f2 | sort | awk '{a[$1]+=1;}END{for(i in a){print a[i]" " i;}}' | sort | head -5
# cut -d' ' -f7 access.log | sort | uniq -c | sort -rn | head -5
```

### sed

功能：Stream EDitor 流编辑器

- 语法	sed [option] 'SCRIPTS' FILE
- 选项：
  - -f直接将 sed 的动作写在一个文件内【调用sed脚本处理文件】
  - -n抑制默认输出【抑制未处理的内容默认输出，常与p命令连用】
  - -e允许在同一行里执行多条命令【;也可以实现】
  - -r支持扩展元字符
  - -iSUFFIX修改源文件，同时创建一个备份文件：源文件名SUFFIX【sed -i.bak '1,10d' test生成一个test.bak备份文件】
- SCRIPT：[Address]\[!]Command
  - Address		
    - 地址空【匹配所有行】
    - $最后一行
    	 line-address	
      - N【第N行】
      - /PATTERN/【正则匹配行】
      - iarq
    - address：
      - 包括行地址
      - N
      - N,M【N到M行】
      - /PATTERN1/,/PATTERN2/【sed '/^a/,/^b/d' test删除第一次以a到以b开头之间的行】
  - Command
    - d删除模式空间的内容
    - p显示模式空间的内容【sed ‘1,2p’ test】【重复模式空间的行】【常与n命令连用】
    - s/PATTERN/REPLACE/FLAG【sed 's/(\[^0-9]\*):([0-9]):([\^0-9]*)/\3\1\2/'】【/可以替换成其他符号，比如s###】

基本命令：

- d
- p
- s///
- a【append追加内容】【a\STRING】【1a\abc】
- i【insert在前面插入内容】【1i\abc】
- =【打印行号】
- l【打印+控制字符$】
- y【字符转换y/abc/ABC/】【将a转换为A将b转换为B将c转换为C】
- w保存指定行到文件
- r读取文件内容到指定行
- n读取下一行到模式空间【next】【-n 'n;p'偶数】【-n 'p;n'奇数】
- c【change】行替换【c\STRING】
- q退出【sed '10q' test读取1-10行后退出】

进阶命令：

- N【读取下一行内容到模式空间，以\n拼接上一行内容【1N\==>1\n2】【'N;s/\n/,/'\==>1\n2====>1,2】
- D【删除模式空间上一行内容（\n前面的内容）不会清空模式空间内容】
- P【打印模式空间上一行内容（\n前面的内容）清空模式空间内容】
- 例子：【N;P;D】【N;P;d】【's/^\$/d/'删除所有空白行】【'/^$/{N;/\n\$/D}'删除空白行保留一行空白行】

高级命令：

- H/h将模式空间【patternspace清空】的内容覆盖h（追加H	'\n'连接）到保持空间【holdspace覆盖】

- G/g将保持空间内容覆盖g（追加G）到模式空间【'H:$g'】【G每行后添加空行a\n[]】

- x交换两个空间的内容

  -  sed 'x' test【abcd】

    \n

    a

    b

    c

  - sed 'H;${x;s/\n/,/g;s/^,//};d\$!d'

  ​

  ​		

./sedsed-1.0 -d -f test.sed test分析sed

https://www.cnblogs.com/lemon-le/p/6061189.html

```shell
exercise:
sed -r 's/^\(192\.168\.0\.1\)/\1localhost/'【's/^192\.168\.0\.1/&localhost/'】
sed 's/digit \([0-9]\)/\1/g'
sed 's/\(love\)able/\1rs/'
sed -n 'n;p' | 'p;n' | '2~2p' | '1~2p'
sed '/test/,/west/{s/$/aaabbb/}'【s/.*/&aaabbb/】
sed '/line1/,/line2/{s/aa bbb/AA BBB/g}'
sed -n '/3/,$p'
sed -n '/3/,+2p'
sed '1!G;h;$!d'
sed -n '$p'
sed '/^$/d;G'
sed 'G'
sed '$='
sed '/^$/!='
习题三：
2.sed '/^1/{H;g}'
sed '/^$/d;3N'
sed 's/^[\t]*//'【's/^[[:blank:]]+//'行首空白】
将文本中的'aaa','bbb','ccc'都替换为'ttt'【s///;s///;s///】
【未出现hello】sed '/hello/!s/yes/no/g'
sed '/\n/!G;s/\(.\)\(.*\n\)/&\2\1/;//D;s/.//'
sed 's/([0-9]+)([0-9]{3}[.]?)/\1,\2/g'
sed -n '$p'
sed 'N;s/\n/\t/'
习题四：
sed '/abc/w /tmp/test' test【保存】
sed '/abc/r /tmp/test' test【匹配内容后】
sed '/4/{p;=}'
sed '/3/{n;d}'
sed '/3/{N;d}'
6.sed 's/^.//'
7.sed 's/\(^.\)./\1/'
8.sed 's/.$//'
9.sed 's/.\(.$\)/\1/'
10.sed 's/\([a-z]*\)[](a-z)*$/\1/'【-r 's/(.*)(\b\w+\b)(\W*$)/\1\3/'单词后可以有任意字符出现任意次】
习题五：
sed '/[0-9]/d'【's/[0-9]//g'】
【时间格式】sed 's/\//:/g'
3.sed -n '1~2p'
4.sed /ss/,/yy/d
5.sed -n '1~2p'
6.sed 'N;$!P;$!D;$d'
8.sed '0~5G'
9.sed -n '/^[abc]/!p'【不显示以abc开头的行】
10.sed '1,20{s/aaa/AAA/g;s/ddd/DDD/g}'
```
