## **1. Learn the concepts (20 minutes)**

Focus on these five areas.

| Concept          | What you need to understand              |
| ---------------- | ---------------------------------------- |
| Linux processes  | How applications run in the background   |
| File permissions | Who can read, write and execute files    |
| Services         | How Linux manages background services    |
| Ports            | How applications receive network traffic |
| DNS              | How domain names resolve to IP addresses |

### **Important Linux commands**

These are commands you'll regularly encounter in Cloud and DevOps roles.

| Command      | Purpose                         |
| ------------ | ------------------------------- |
| `ps aux`     | List running processes          |
| `top`        | Monitor CPU and memory          |
| `df -h`      | Check disk usage                |
| `free -h`    | Check memory                    |
| `chmod`      | Change file permissions         |
| `systemctl`  | Manage Linux services           |
| `journalctl` | Inspect system logs             |
| `ss -tulpn`  | Inspect listening network ports |
| `curl`       | Test HTTP connectivity          |
| `dig`        | Investigate DNS resolution      |

**Understand this example:**
Suppose your application is running on port 8080, but users cannot access it.
You should investigate:
1. Is the application process running?
2. Is the application listening on port 8080?
3. Is the application listening on the correct network interface?
4. Is the operating system firewall blocking the connection?
5. Is the AWS Security Group allowing the traffic?
This is how you approach an actual production issue.

## **2. Hands-on lab: Diagnose a Linux web server (45 minutes)**
**Objective:** Run a small web server, inspect its process and network port, test connectivity and investigate a failure.
You can use Ubuntu, another Linux machine, WSL or an existing Linux VM.
### **Step 1 – Check your Linux environment**
Open your terminal and execute:
```
uname -a
whoami
pwd
df -h
free -h
```
Observe:
- Your Linux kernel information.
- Your current username.
- Your working directory.
- Available disk space.
- Available memory.

### **Step 2 – Start a web server**
Check whether Python is installed:
```
python3 --version
```
Create a directory:
```
mkdir devops-week2
cd devops-week2
```
Create a test HTML page:
```
echo "Welcome to my DevOps lab" > index.html
```
Start a simple web server
```
python3 -m http.server 8000 --bind 127.0.0.1
```
Keep this terminal running.

### **Step 3 – Investigate the running application**
Open another terminal.
Check the listening port:
```
ss -ltn
```
Test the application:
```
curl http://127.0.0.1:8000
```
Expected response:
```
Welcome to my DevOps lab
```
Check the process:
```
ps aux | grep http.server
```
You've now verified three things:
- The application process exists.
- A TCP port is listening.
- The HTTP request receives a response.

### **Step 4 – Simulate an application failure**
Return to your first terminal and press:
`Ctrl + C`
This stops the web server.
Now run:
```
curl --connect-timeout 3 http://127.0.0.1:8000
```
You should get a connection failure.
Investigate:
```
ss -ltn
ps aux | grep http.server
```
**Question:** Why did the application stop responding even though your Linux machine is still running?
Answer: The server process was stopped, so nothing was listening on port 8000.
This distinction is important in production troubleshooting.

## **3. Mini project: Build a Bash server health-check script (15 minutes)**
Now let's automate part of the troubleshooting process.
Create a file:
```
nano health-check.sh
```

Paste this script:
```
#!/usr/bin/env bash
URL="${1:-http://127.0.0.1:8000}"
echo "===== SERVER HEALTH CHECK ====="
echo "Checking: $URL"
# Check HTTP availability
if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl is not installed"
    exit 2
fi

HTTP_CODE=$(curl -sS -o /dev/null \
    -w "%{http_code}" \
    --connect-timeout 2 \
    --max-time 5 "$URL" 2>/dev/null) || HTTP_CODE="000"

if [[ "$HTTP_CODE" =~ ^2[0-9][0-9]$ ]]; then
    echo "Application status: HEALTHY"
    echo "HTTP status: $HTTP_CODE"
else
    echo "Application status: UNHEALTHY"
    echo "HTTP status: $HTTP_CODE"
fi

# Check disk usage
echo ""
echo "Disk usage:"
df -h /

echo "===== CHECK COMPLETED ====="

```
Make it executable:
```
chmod +x health-check.sh
```
Run it:
```
./health-check.sh
```
Or specify another URL:
```
./health-check.sh http://127.0.0.1:8000
```
### **Expected results**

| Situation         | Expected output |
| ----------------- | --------------- |
| Server running    | HEALTHY         |
| Server stopped    | UNHEALTHY       |
| HTTP 404 response | UNHEALTHY       |
| curl unavailable  | ERROR           |

Note: This basic health check treats only HTTP 2xx responses as healthy. A production health check would also consider application-specific readiness, dependency status and meaningful exit codes.

## **4. Troubleshooting challenge (5 minutes)**
Imagine you're working as a DevOps Engineer.
Your team reports:
> The application was working yesterday. Today, users are receiving connection errors.
What would you investigate?
**Your investigation checklist**
- Check whether the application process is running.
- Check whether the expected port is listening.
- Check application logs.
- Check disk and memory utilisation.
- Check DNS resolution.
- Check firewall and network configuration.

## **5. Interview preparation (10 minutes)**
Try to answer these four questions.
**Q1. What is the difference between a process and a service in Linux?**
A process is an executing program. A service is a background system function generally managed by a service manager such as systemd.

**Q2. What happens when you execute chmod 755 file.sh?**
The owner receives read, write and execute permissions. Group and others receive read and execute permissions.

**Q3. What is the difference between TCP and UDP?**
TCP provides connection-oriented, reliable and ordered delivery. UDP is connectionless and does not guarantee delivery or ordering.

**Q4. How would you troubleshoot a service that is running but inaccessible?**
Check listening sockets, application logs, bind address, firewall rules, DNS and network routing. A running process alone doesn't guarantee reachability.

| [Linux Journey](https://linuxjourney.com/?utm_source=chatgpt.com)                                   | Linux fundamentals    |
