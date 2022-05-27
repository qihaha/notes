#!/bin/bash
workdir=$(cd $(dirname $0); pwd)
if [[ $# -ne 1 || ! -d $1 ]];then
  echo "请指定有效的目录"
  exit 10
fi

root_id=""
nodes=""
links=""
echo "---------------------------------------------------------------"
cd $1
pomfile_list=`find . -name pom.xml ! -path ./pom.xml | grep -v ./test/`
for pomfile in $pomfile_list
do
  echo -e "\033[31m $pomfile \033[0m" 
  artifactId=`xmllint --xpath '/*[local-name()="project"]/*[local-name()="artifactId"]/text()' $pomfile`
  dependency_artifactId="<artifactId>${artifactId}</artifactId>"
  result=` grep -rl --include="*/*/pom.xml" $dependency_artifactId ./* | grep -v $pomfile | grep -v ./test/`
  dirname=`echo $pomfile | sed -r "s/\.\/(.*)\/pom\.xml/\1/g"`
  nodes=${nodes}'{"id":"'${dirname}'","text":"'${dirname}'"},'
  if [ -z "$result" ]; then
    root_id='"rootId": "'${dirname}'",'
  else
    for dp in $result
    do
      dirname2=`echo $dp | sed -r "s/\.\/(.*)\/pom\.xml/\1/g"`
      links=$links'{"from":"'$dirname'","to":"'$dirname2'"},'
    done
  fi
  echo $result
  echo "---------------------------------------------------------------"
done
echo '{'${root_id}'"nodes": ['${nodes%*,}'],"links": ['${links%*,}']}'
cd $workdir
