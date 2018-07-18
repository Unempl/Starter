ip地址：

- 子网掩码
- dns（域名到ip的解析）114.114.114.114、223.5.5.5、8.8.8.8
- 网关

tcp/ip协议栈

osi七层协议

###分区方式：

1、MBR引导扇区512byte（446byte引导程序、64byte分区表、2byte结束标志【aa55】）hexdump xxx.img/*最多四个主分区*/

主分区4个、扩展分区（占一个主分区）->逻辑分区

2、GPT最大支持18个EB硬盘（需要主板和系统的支持）



挂载：将设备与目录关联起来，访问目录即访问设备

### 文件系统类型：描述文件在分区上组织方法和数据结构

​	- windows：FAT32\NTFS\exFAT

​	- linux：ext2、ext3、ext4、xfs



### 挂载

挂载光盘：

1、mkdir /media/cd

2、mount -t iso9660 /dev/sr0 /media/cd	【设备】【挂载点】

mount -t FILESYSTEM_TYPE DEVICE DIR



###常用命令

ls -d 查看目录本身

```shell
[root@zlydevps dev]# ls /etc -ld
drwxr-xr-x. 80 root root 8192 7月   2 09:43 /etc
```

file 查看文件类型

```
[root@zlydevps dev]# file /dev/sr0
/dev/sr0: block special

[root@zlydevps dev]# file /etc/fstab
/etc/fstab: ASCII text
```

rm： -rf | -v | -i

cd：- | ~

dd | bash FILE | nano FILE

统计数量：wc -l

du -sh FILE 查看文件大小【summary | human-readable】

ll /etc -h

hexdump FILENAME

runlevel 查看运行级别

ifconfig eth0 10.1.1.4

free查看内存情况

tree /etc

ls -d 当前目录

alias 命令的别名【alias mountcd='mount -t iso9660 /dev/cdrom /media/cd'】



## 网络

- OSI七层
  - ARP泛洪、CAM
- MAC 交换机
- IP
- TCP/UDP
- 数据的封装和解封装过程【帧MAC头、IP头、TCP头】
- DNS
- NAT
- 网关：路由【公网、私网】
- 子网掩码
- 协议
  - ICMP 【echo request | echo reply】
  - 路由协议（路由表）



```shell
## NAT模式 ##
ONBOOT = 	yes
NM_CONTROLLED = no
BOOTPROTO = static
IPADDR = 192.168.120.100
NETMASK = 255.255.255.0
GATEWAY = 192.168.120.2
DNS1 = 114.114.114.114
:wq
service network restart

1.编辑虚拟网络编辑器：
查看dhcp分配网段	192.168.120.0/24
NAT设置：网关：192.168.120.2
2.调整为NAT模式：自定义>VMnet8
3.修改虚拟网卡配置文件：BOOTPROTO = static | IPADDR = 192.168.120.100 | NETMASK = 255.255.255.0 | GATEWAY = 192.168.120.2 | DNS1 = 114.114.114.114
4.重启网络服务 systemctl restart network(centos7) | /etc/init.d/network restart	(centos6) | sudo /etc/init.d/networking restart(ubuntu12)
查看dns配置文件：cat /etc/resolv.conf【nameserver 114.114.114.114】

```



```shell
网卡配置文件：【ubuntu】/etc/network/interfaces | 【centos7】/etc/sysconfig/network-scripts下ls
auto eth0
iface eth0 inet static
address 192.168.139.3
netmask 255.255.255.0
gateway 192.168.139.2
# dns-nameservers 114.114.114.114
```

```shell
ubuntu	语言恢复成英文
修改/etc/default/locale内容
LANG="en_US.UTF-8"
LANGUAGE="en_US:en"

$ locale-gen -en_US:en
```

ldd COM	查看命令依赖的库文件	：ldd /bin/ls

cpu架构：i386、i686、x86__64、amd64、ARM（移动端）、Sparc

###软件管理

####RPM（.rpm）【缺点，依赖文件】

可执行性文件：/bin | /sbin | /usr/bin | /usr/sbin...

配置文件：/etc

库文件：/lib | /lib64 | /usr/lib | /usr/lib64

```shell
[root@zlydevps network-scripts]# uname -r
3.10.0-514.el7.x86_64

rpm -q(query) 查找所有已安装rpm包
		-qa 包名
		-qf FILE 根据文件查找文件包名称
		-ql 包名 list列出软件包文件列表
		-qi 包名 information查询软件包信息
[root@zlydevps /]# which vim
/usr/bin/vim
[root@zlydevps /]# rpm -qf /usr/bin/vim
vim-enhanced-7.4.160-1.el7_3.1.x86_64
	---------
	-e（erase） 卸载
	---------
	-ivh（install、verbose冗长、hash以'#'显示安装进度）安装 # 显示命令执行过程信息
	---------
	-u 更新/升级
	# rpm包对内核升级
	rpm -Uvh kernel-firmware-2.6.32-754.el6.noarch.rpm(升级内核依赖)
	rpm -ivh kernel-2.6.32-754.el6.x86_64.rpm(安装内核)
	uname -r
	# 导入证书
	rpm --import 证书路径
```

```shell
ftp客户端用法：
1.进入/media/cd/Packages
2.rpm -ivh lftp-4.0...... .rpm
3.cd /（会下载到该目录下）
4.lftp 10.1.1.251
5.get FILENAME
6.bye | exit
```



#### YUM

```shell
【用户】仓库配置文件：/etc/yum.repos.d
底层调用rpm安装软件
缓存数据文件
	-------------
	查询
	yum list(all | installed | NAME)	列出仓库所有软件包 | 已安装软件包 | 软件名
	yum info NAME 查看软件信息
	安装
	yum install NAME
	卸载
	yum remove NAME
	升级
	yum update NAME
	-------------
	自动应答（yes）
	yum -y
	删除仓库配置文件：rm /etc/yum.repos.d/* -rf
	创建路径*******：/etc/yum.repos.d/*.repo
	vi /etc/yum.repos.d/local.repo
	格式：
	[REPO_NAME]
	name=			#仓库描述
	baseurl=ftp://10.1.1.251/cdrom(ftp://或本地file:///media/cd) | https://MIRROR_URL		#仓库位置
	enabled=0 | 1		#是否激活仓库
	gpgcheck=0 | 1			#是否启用证书检查
	gpgkey=			#指定证书位置，自动导入(指定URL)
	仓库配置步骤：1、创建仓库配置文件
						2、清除原仓库缓存文件 yum clean all
						3、正常使用仓库 yum repolist
						
  nginx
  netstat -tulnp查看守护进程
  iptables -L | -F
  /etc/init.d/iptables save
  
  # 配置epel仓库安装nginx
  下载epel-release包（网易镜像）
  rpm -ivh 包路径
  yum clean all
  yum install nginx
  nginx
  netstat -tulnp（80端口nginx）
  关闭防火墙 iptables -F | /etc/init.d/iptables save
  在浏览器输入服务器ip
```

```shell
http:
```

```shell
配置仓库配置文件
DPKG
deb 镜像/debian
apt-cache 
apt-get install | update更新索引 | remove | purge删除 | upgrade升级软件
源码编译安装：rpm功能固定 | 手动编译功能可选
```

```shell
Ubuntu && Debian【https://blog.csdn.net/u014114046/article/details/52162482】
首先，使用su root切换至超级用户权限；
然后，gedit /etc/apt/sources.list，打开源列表文件，这里没有进行备份，如果需要，也可以用cp命令进行下备份；
将以下所示的源列表之一全部复制到sources.list文件中，替换原有内容；
最后，保存并关闭已经打开的source.list文件，在终端输入 apt-get update命令。
```

```c
$ vi test.c
#include <studio.h>
int main(){
  printf("helloworld!");
}

$ gcc -o test.o test.c
$ ./test.o		// 执行已编译的文件
```

### 压缩、解压缩

打包 tar 打包并压缩文件： tar -czvf【create | gzip | verbose | filename】 FILENAME PATH

压缩 gzip tar -xzvf |-xf | xf PATH

```shell
1.nginx安装源码 wget http://nginx.org/download/nginx-1.14.0.tar.gz
2. 解压
3. 配置PATH路径
4.	$ ./configure --prefix=/usr/local/nginx--with-http-ssl-module
5.make
6.make install
-------------------
缺少库文件安装：yum install pcre-devel
nginx -s stop

1.wget
2.tar xf
3.cd nginx-1.44
4.$ ./configure --prefix=/usr/local/nginx --with-http-ssl-module【可能出现缺少库文件安装】
5.make && make install
6.nginx -s stop
7./usr/local/nginx/sbin/nginx
8.输入ip
```

## FHS

统一各版本的目录结构

层次：

/

```shell
#实现系统基本功能
bin基本的命令
sbin系统管理相关命令
-------------------
dev：块设备/dev/sda1 | 字符设备/dev/ttyX | /dev/null接受任何数据无任何反馈 【ifconfig > /dev/null】 | /dev/zero 零字符设备，可以产生无限个0【dd if=/dev/sda of=mbr.img bs=512 count=1】
home
root
lib64库
lib
media可移动设备
mnt挂载普通的文件系统（分区）
**proc内核和进程信息映射文件/proc/cpuinfo | /proc/meminfo | /proc/bus总线 | /proc/sys内核相关参数【/net/ipv4/icmp_echo_ignore_all忽略icmp所有报文 | tcp_syn_retries （tcp syn重传次数）| ip_forward ip转发】
--------修改主机名----------
echo "localhost_name" > /proc/sys/kernel/hostname
$ hostname
---------------------------
srv服务数据（已弃用，新目录/var）
tmp临时文件
var
boot
etc：配置文件 
/etc/inittab默认运行级别配置文件（开机后进入什么模式）
#   0 - halt (Do NOT set initdefault to this)
#   1 - Single user mode（用户系统修复 | root密码丢失）
#   2 - Multiuser, without NFS (The same as 3, if you do not have networking)
#   3 - Full multiuser mode
#   4 - unused（保留未使用）
#   5 - X11（可视图形化环境）
#   6 - reboot (Do NOT set initdefault to this)
# init X 切换运行级别
/etc/fstab开机自动挂载
lost+found丢失+查找
**misc不便于归类文件
**net
**sys硬件参数映射文件
opt原第三方软件安装目录（现转移到/usr/local）
**selinux
usr
```

/usr

```shell
# 实现系统扩展功能				
bin 基本命令
sbin 系统命令 | 非重要的系统命令
------------------------------
/local/bin | /sbin
/share：doc软件文档 | man帮助手册
```

/var

```shell
tailf FILENAME查看日志命令 tailf /var/log/secure
/log	日志文件 messages系统大部分日志 | dmesg设备相关日志 | maillog邮件日志 | secure认证相关
/run	进程运行时相关文件（pid文件）可以kill
/spool		/var/spool/mail 用户邮箱
```

```shell
创建：vi/vim/nano | touch FILENAME【access change modify】| mkdir -p DIR
查看：cat | ls | head -n N默认前十行 | tailf | more分屏浏览文件内容【空格下一页 | b上一页】 | less | tail -n N查看末尾N行
移动：mv -v | -i source dest重命名 | source directory移动文件
拷贝：cp -a归档【preserve all attributes】 | -R递归【拷贝目录】 | -v拷贝过程信息 | -i交互 source dest拷贝+重命名 | source directory将多个文件拷贝到目录中
删除：rm -r | -f | -i | -v
```

```shell
通配符：
路径中匹配文件名 *任意个字符 ?单个任意字符 []字符集合中任意一个 POSIX定义标准字符集合[:alpha:][:digit:][:upper:][:lower:][:alnum:]数字字母[:blank:]空格制表符
ls [[:alpha:]]5

```

