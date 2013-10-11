require "json"
require "uri"
require 'digest/md5'

config = JSON.parse(IO.read("config.json"), {"symbolize_names" => true})

#we have a github webhook payload
if params['commits']

    #build a list of changed files
    changed = []
    params['commits'].each do |commit|
        changed = changed | commit['added'] | commit['removed'] | commit['modified']
    end

    #find the corresponding repository
    repositories = []
    webhookUri = URI(params['repository']['url'])
    config['repositories'].each do |repository|
        sourceUri = URI(repository['source'])
        if webhookUri.host + webhookUri.path == sourceUri.host + sourceUri.path
            repositories.push(repository)
            break
        end
    end
else
    repositories = config['repositories']
end

if repositories.count > 0

    cmd = "export GIT_EXEC_PATH=`pwd`/__debs__/usr/lib/git-core && export GIT_SSL_NO_VERIFY=true;\n"

    repositories.each do |repository|
        uri = URI(repository['source'])
        dir = Digest::MD5.hexdigest(uri.host + uri.path)

        subtrees = []
        repository['subtrees'].each do |subtree|

            if changed
                changed.each do |path|
                    if path.start_with?(subtree['path']) and !subtrees.include?(subtree)
                        subtrees.push(subtree)
                    end
                end
            else
                subtrees.push(subtree)
            end

        end

        if subtrees.count > 0
            cmd += "git clone " + repository['source'] + " --branch " + repository['branch'] + " " + dir
            cmd += " && cd " + dir

            subtrees.each do |subtree|
                cmd += " && git subtree -q push --prefix=" + subtree['path'] + " " + subtree['dest'] + " " + subtree['branch']

                #branch = Digest::MD5.hexdigest(subtree['path'])
                #cmd += "git subtree split -q --prefix=" + subtree['path'] + " --branch=" + branch + " && "
                #cmd += "git push " + subtree['dest'] + " " + branch + ":" + subtree['branch'] + ";\n"
            end

            cmd += " && cd .. && rm -rf " + dir + ";"
        end
    end

    if (params['dry-run'])
        print "> " + cmd + "\n"
    else
        exec(cmd)
    end
end