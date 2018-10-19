if [ $# -lt 1 ]; then
    echo "Usage: ./build.sh [in_file_path]
    Example: ./build.sh \"lead_info\""
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
t=$1
in_path="$path/src/$t/$t.html"
in_data="$path/src/$t/data.json"
out_path="$path/build/"

echo -e "\nGenerating template: /build/$t.html\n"
echo -e "\tIn: /src/$t/$t.html"
echo -e "\tData: /src/$t/data.json\n"

ruby ruby/build.rb $in_path $in_data $out_path

echo "Waiting for changes..."

m1=`stat -f '%m' $in_path`
m2=`stat -f '%m' $in_data`

while : ; do
    sleep 1s
    n_m1=`stat -f '%m' $in_path`
    n_m2=`stat -f '%m' $in_data`
    if [[ n_m1 -gt m1 || n_m2 -gt m2 ]] ; then
        echo "Change detected"
        echo -e "\nGenerating template: /build/$t.html\n"
        ruby ruby/build.rb $in_path $in_data $out_path
        m1=`stat -f '%m' $in_path`
        m2=`stat -f '%m' $in_data`
    fi
done