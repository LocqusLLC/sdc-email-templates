if [ $# -lt 3 ]; then
    echo "Usage: ./build.sh in_file in_data out_file
    Example: ./build.sh \"/foundation/dist/lead.html\" \"/data/lead.json\" \"/build/lead.html\""
    exit 1
fi

# Install ruby dependencies
file="./ruby/Gemfile.lock"
if [ ! -e $file ]; then
    cd ruby
    has=`gem list -i "^bundler$"`
    if [ "false" == $has ]; then
        sudo gem install bundler
    fi
    bundle install
    cd ..
fi

path=`pwd`
ip=$1
id=$2
op=$3
in_file="$path$ip"
in_data="$path$id"
out_file="$path$op"

echo -e "\nGenerating template: $op\n"
echo -e "\tIn: $ip"
echo -e "\tData: $id"

ruby ruby/build.rb $in_file $in_data $out_file

echo -e "Waiting for changes...\n"

m1=`stat -f '%m' $in_file`
m2=`stat -f '%m' $in_data`
count=1
while : ; do
    sleep 1s
    n_m1=`stat -f '%m' $in_file`
    n_m2=`stat -f '%m' $in_data`
    if [[ n_m1 -gt m1 || n_m2 -gt m2 ]] ; then
        echo "Change detected $count"
        echo -e "\nGenerating template: $op\n"
        ruby ruby/build.rb $in_file $in_data $out_file
        m1=`stat -f '%m' $in_file`
        m2=`stat -f '%m' $in_data`
        count=$((count+1))
    fi
done