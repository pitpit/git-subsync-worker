require "json"
require "uri"
require 'digest/md5'
require 'logger'

config = JSON.parse(IO.read("config.json"), {"symbolize_names" => true})
logger = Logger.new(STDERR)

#look foor a github webhook payload
match = URI.unescape(payload).match(/&payload=(.+)$/)
if match
    payloadParams = JSON.parse(match[1])

    #build a list of changed files
    changed = []
    payloadParams['commits'].each do |commit|
        changed = changed | commit['added'] | commit['removed'] | commit['modified']
    end

    #find the corresponding repository
    repositories = []
    webhookUrl = URI(payloadParams['repository']['url'])
    config['repositories'].each do |repository|
        repositoryUrl = URI(repository['url'])
        if (repositoryUrl.host + repositoryUrl.path).start_with?(webhookUrl.host + webhookUrl.path)
            repositories.push(repository)
            break
        end
    end
else
    repositories = config['repositories']
end

if repositories.count > 0

    cmd = ""
    cmd += "mkdir ~/.ssh && chmod 700 ~/.ssh"
    cmd += " && mv id_rsa ~/.ssh && mv config ~/.ssh\n"

    cmd += "export GIT_EXEC_PATH=`pwd`/__debs__/usr/lib/git-core\n"

    cmd += "git config --global http.sslVerify false\n"

    repositories.each do |repository|
        dir = Digest::MD5.hexdigest(repository['url'])
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
            cmd += "git clone " + repository['repository'] + " --branch " + repository['branch'] + " " + dir
            cmd += " && cd " + dir

            subtrees.each do |subtree|
                logger.info("sync #{repository['repository']}/#{subtree['path']} to #{subtree['repository']}")
                #$stderr.puts "sync #{repository['url']}:#{subtree['path']} to #{subtree['repository']}"
                #puts "sync #{repository['url']}:#{subtree['path']} to #{subtree['repository']}"
                branch = Digest::MD5.hexdigest(subtree['path'])
                cmd += " && git subtree -q split --prefix=" + subtree['path'] + " --branch=" + branch
                cmd += " && git push --force " + subtree['repository'] + " " + branch + ":" + subtree['branch']
            end

            cmd += " && cd .. && rm -rf " + dir + ";"
        end
    end

    if params['dry-run']
        print "> " + cmd + "\n"
    else
        exec(cmd)
    end
end