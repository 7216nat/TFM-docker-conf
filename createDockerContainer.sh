#!/bin/bash
TARGET_BRANCH="needlefish"


FOLDER=$PWD/AGL
SHOULD_REBUILD_IMAGE=n
if [ -d "$FOLDER" ]
then
    echo "$FOLDER is an existing directory. Continuing will erase the folder's content. Should we continue? (y/n)"
    read SHOULD_REBUILD_IMAGE
else
    echo "$FOLDER does not exist. Proceeding"
    SHOULD_REBUILD_IMAGE=y
fi

if [ $SHOULD_REBUILD_IMAGE = y ]
then
    rm -rf $FOLDER
    mkdir -p $FOLDER
    echo "Running..."
    mkdir -p $FOLDER/out
    cd $FOLDER
    echo "
#!/bin/bash
AGL_TOP=\$HOME/AGL
cd \$AGL_TOP
mkdir $TARGET_BRANCH && cd $TARGET_BRANCH
repo init -b $TARGET_BRANCH -u https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo
repo sync && cd \$AGL_TOP/$TARGET_BRANCH
source meta-agl/scripts/aglsetup.sh -m raspberrypi4 -b raspberrypi4 agl-demo agl-devel
echo \"DL_DIR=\\"\$AGL_TOP/downloads/\\"\" >> \$AGL_TOP/site.conf
echo \"SSTATE_DIR=\\"\$AGL_TOP/sstate-cach/\\"\" >> \$AGL_TOP/site.conf
ln -sf \$AGL_TOP/site.conf conf/
echo \"INHERIT+=\\"buildhistory\\"\" >> conf/local.conf
echo \"BUILDHISTORY_COMMIT=\\"1\\"\" >> conf/local.conf
echo \"INHERIT+=\\"rm_work\\"\" >> conf/local.conf
echo \"EXTRA_IMAGE_FEATURES+=\\"tools-sdk\\"\" >> conf/local.conf
echo \"EXTRA_IMAGE_FEATURES+=\\"tools-debug\\"\" >> conf/local.conf
echo \"EXTRA_IMAGE_FEATURES+=\\"eclipse-debug\\"\" >> conf/local.conf
nohup bitbake agl-demo-platform-crosssdk &" > $FOLDER/build.sh

    wget -N https://github.com/7216nat/TFM-docker-conf/raw/master/Dockerfile
    docker build \
    --build-arg USER_NAME=$USER \
    --build-arg HOST_UID=`id -u` \
    --build-arg HOST_GID=`id -g` \
    --build-arg GIT_USER_NAME=nat7216 \
    --build-arg GIT_EMAIL=xukchen@ucm.es \
    -t agl:demo \
    .
    echo "Done."
else
    echo "Ok. Bye."
fi

echo "Should I run the docker container? (y/n)"
read
if [ $REPLY = y ]
then
    echo "Running..."
    docker run -d \
    -it \
    --name demo_agl \
    -v $FOLDER/out:/home/$USER/AGL \
    agl:demo
fi
echo "Ok. Bye."
