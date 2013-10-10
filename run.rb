require "json"

config = JSON.parse(IO.read("config.json"), {"symbolize_names" => true})

#todo: if its a github webhook only run corresponding task

tasks = config['tasks']
config['tasks'].each do |task|


    cmd = "git clone " + task['source'] + " --branch " + task['branch'] + " tmp/ && "
    cmd += "cd tmp/ && "
    cmd += "git subtree split --prefix=" + task['subtree'] + " --branch=splitted && "
    cmd += "git push " + task['destination'] + " splitted:" + task['branch']
    print "> " + cmd + "\n"

    if (not params['dry-run'])
        exec(cmd)
    end
end



