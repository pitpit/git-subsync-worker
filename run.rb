require "json"
require "uri"
require 'digest/md5'

config = JSON.parse(IO.read("config.json"), {"symbolize_names" => true})

#we have a github webhook payload
if params['repository'] and params['repository']['url']

    currentUri = URI(params['repository']['url'])
    repositories = []

    config['repositories'].each do |repository|
        sourceUri = URI(repository['source'])
        if currentUri.host + currentUri.path == sourceUri.host + sourceUri.path

            repositories.push(repository)

            #todo check in commits that there is added, modified or deleted file in correpsonding subtree (do nothing if not)
            #...
        end
    end
else
    repositories = config['repositories']
end

# cmd = "export GIT_EXEC_PATH=`pwd`/__debs__/usr/lib/git-core && "
cmd = ""
repositories.each do |repository|
    uri = URI(repository['source'])
    dir = Digest::MD5.hexdigest(uri.host + uri.path)

    cmd += "git clone " + repository['source'] + " --branch " + repository['branch'] + " " + dir + " && "
    cmd += "cd " + dir + ";\n"

    repository['subtrees'].each do |subtree|
        branch = Digest::MD5.hexdigest(subtree['path'])

        cmd += "git subtree split -q --prefix=" + subtree['path'] + " --branch=" + branch + " && "
        cmd += "git push " + subtree['dest'] + " " + branch + ":" + subtree['branch'] + ";\n"
    end

    cmd += "cd .. && rm -rf " + dir + ";"
end

if (params['dry-run'])
    print "> " + cmd + "\n"
else
    exec(cmd)
end