# Webhook receiver for GitLab
This webhook receiver accepts GitLab webhooks and parses them to execute specified tasks.  
  
## Installation  
By default, this tool is listening on port 8000. If this port is already in use or you want to change it anyways, you have to modify the `@port`-variable in `/opt/scripts/gitlab/webhook_receiver/webhook_receiver.rb`.  
  
>You should also verify that the port is opened in your firewall.  

Execute the following command to install the tool:
```bash
wget https://gitlab.zeus-coding.de/arlindne/webhook_receiver/raw/master/install -O - | sudo bash
```
  
To remove the tool, execute the following command:
```bash
wget https://gitlab.zeus-coding.de/arlindne/webhook_receiver/raw/master/remove -O - | sudo bash
```  
  
>**Hint:** Executing the commands above does not work with the root user for some reason.  
## Configuration
This tool is using json files for configuration.  
Each project that should be handled needs a separate json config file.  
There is already an template available (you can copy and modify it to fit your needs).  
The files are located in `/opt/scripts/gitlab/webhook_receiver/config/`.  
  
### JSON modification  
The first 5 members are necessary (except the `ssh_key`, which is only needed if `ssh` is `true`).  
The event array holds all events that should be handled. An event cannot be handled twice (currently).  
An event consists of 3 members:   
  
|||
| :--- | :--- |
| `event`    | - must match the event string of the webhook|
| `required`|  - can contain any member of the `object_attributes` parent (for an `merge event`, `issue event`, `commit event`, `wiki_page event`)|
| `action` |   - consists of `checkout_branch` (the branch to be used), `strategy` (which git strategy to execute - clone, pull, etc.), `execute` (executes a shell command)|  
  
You can check the webhook members for all events at the [official GitLab Wiki](https://docs.gitlab.com/ee/user/project/integrations/webhooks.html#events)