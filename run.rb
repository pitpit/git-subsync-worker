require "json"
require "uri"

config = JSON.parse(IO.read("config.json"), {"symbolize_names" => true})

#we have a github webhook payload
if params['repository'] and params['repository']['url']

    currentUri = URI(params['repository']['url'])
    repositories = []
    config['repositories'].each do |task|
        sourceUri = URI(task['source'])
        if currentUri.host +  currentUri.path == sourceUri.host + sourceUri.path

            #the repository is configured
            repositories.push(task)

            #todo check in commits that there is added, modified or deleted file in correpsonding subtree (do nothing if not)
        end
    end
else
    repositories = config['repositories']
end

repositories.each do |repository|
    cmd = "export GIT_EXEC_PATH=`pwd`/__debs__/usr/lib/git-core && "
    cmd += "git clone " + repository['source'] + " --branch " + repository['branch'] + " tmp/ && "
    cmd += "cd tmp/ && "
    cmd += "git subtree split -q --prefix=" + repository['subtree'] + " --branch=splitted && "
    cmd += "git push " + repository['destination'] + " splitted:" + repository['branch'] + " && "
    cmd += "cd .. && rm -rf tmp/"

    if (params['dry-run'])
        print "> " + cmd + "\n"
    else
        exec(cmd)
        print "imported " + repository['subtree']
    end
end