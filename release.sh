#!/bin/bash -x

VERSION=$1

SKIP_CHANGELOG=$2

BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [[ "${BRANCH}" != "master" ]] && [[ "${BRANCH}" != "main" ]]
then
  echo "ERROR: releases can only be done from the master/main branch"
  exit 1
fi

behind=$(git log HEAD..origin/${BRANCH} --oneline)
if [[ "${behind}" != "" ]] ; then
    echo "WARNING: local is not up to date with remote!"
    echo "${behind}"
    read -p "Press enter to continue anyway... "
fi

if [[ -z ${VERSION} ]]; then
    echo "ERROR: missing first argument (release version)"
    exit 1
fi

if git rev-parse "$VERSION" >/dev/null 2>&1; then
    echo "ERROR: tag/release already exists. Cannot over overwrite it"
    exit 1
fi

echo "INFO: tag and release ${VERSION}"

TARGET=deploy

do_push() {
    echo "INFO: PUSHING changes."
    git push
}

do_push_tag() {
    echo "INFO: PUSHING tag ${VERSION}."
    git push origin ${VERSION}
}

create_tag() {
    echo "INFO: CREATING tag ${VERSION}."
    git tag ${VERSION}
}

tag_release() {
    # make the release tag
    git add CHANGELOG.md
    git commit -m "release ${VERSION}"
    do_push
    create_tag
    do_push_tag
}

do_tag() {
    echo "INFO: TAGGING ${VERSION}"
    tag_release
    echo
}

update_changelog() {
    changelog_file="CHANGELOG.md"
    text="$1"
    sed -i.bck "2i\\
${text}
" ${changelog_file}
}

do_changelog() {
    changelog_ready="n"
    while [[ "${changelog_ready}" == "n" ]]
    do
        release_headline="## [${VERSION}] - $(date +%Y-%m-%d)"
        added='### Added'
        changed='### Changed'
        newline="placeholder"
        while true
        do
            read -p "added (empty line to stop writing): " newline
            if [[ -z $newline ]]
            then
                break
            else
                added=${added}' \
 - '${newline}
            fi
        done

        newline="placeholder"
        while true
        do
            read -p "changed (empty line to stop writing): " newline
            if [[ -z $newline ]]
            then
                break
            else
                changed=${changed}'\
 - '${newline}
            fi
        done

        full_changelog=${release_headline}'\
'${added}'\
'${changed}
        printf "Your new CHANGELOG entry is:\n\n${full_changelog}\n\n"
        read -p "continue? (y/n): " changelog_ready
    done
    update_changelog "${full_changelog}"
}

cleanup() {
    git status
}

#
# add entries to CHANGELOG.md
#

if [[ -z $SKIP_CHANGELOG ]]; then
    do_changelog
fi

#
# tag release
#

do_tag

#
# cleanup
#

cleanup
