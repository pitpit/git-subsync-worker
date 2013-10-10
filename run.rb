require "json"

config = JSON.parse(IO.read("config.json"), {"symbolize_names" => true})

#todo: if its a github webhook only run corresponding task

tasks = config['tasks']
config['tasks'].each do |task|
    cmd = "ROOT=`pwd` && "
    cmd += "git clone " + task['source'] + " --branch " + task['branch'] + " tmp/ && "
    cmd += "cd tmp/ && "
    cmd += "git --exec-path=$ROOT/__debs__/usr/lib/git-core subtree split --prefix=" + task['subtree'] + " --branch=splitted && "
    cmd += "git push " + task['destination'] + " splitted:" + task['branch']

    if (params['dry-run'])
        print "> " + cmd + "\n"
    else
        exec(cmd)
    end
end



