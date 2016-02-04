# This script adds Security Scheme Definition to the RAML file
# To generate the starter RAML file, install the JAX-RS to RAML eclipse
# plugin:
#  https://github.com/mulesoft/raml-for-jax-rs/blob/master/eclipseplugin.md
# And generate the RAML file into ./WebContent directory

set -e

TARGET_FILE="./WebContent/api.raml"
CAT="/bin/cat"
TEMPFILE=`mktemp`

$CAT <<ENDTEXT > ${TEMPFILE}
securitySchemes:
  - userKey:
      description: User Key for API authentication
      type: x-user-key
      describedBy:
        queryParameters:
          Authentication:
            type: string
securedBy: [userKey]
ENDTEXT

function addDisplayName {
  DESCRIPTION="description: $1"
  DISPLAYNAME="displayName: $2"

  sed -i '' -n "p;s/^\([ \t]*\)${DESCRIPTION}/\1${DISPLAYNAME}/p" ${TARGET_FILE}
}

if ! grep -q "securitySchemes" "${TARGET_FILE}"; then
	# Add security Scheme after "protocols:"
	sed -i '' "/protocols.*/r ${TEMPFILE}" ${TARGET_FILE}

	# Add displaynames
	addDisplayName "Returns list of entries matching the query" "queryPhonebook"
	addDisplayName "Adds entry to phonebook" "create"
	addDisplayName "Returns entry with provided ID" "getEntry"
	addDisplayName "Updates an existing entry in the phonebook" "update"
	addDisplayName "Deletes an existing entry from the phonebook" "deleteEntry"
	addDisplayName "Creates new user entry" "createUser"
	addDisplayName "Returns list of favorite entries" "getFavorites"
	addDisplayName "Sets the favorite status of an entry in the phonebook" "setFavorite"

	# Remove "headers:\nAuthorization:" from the parameters
	sed -i '' '/headers:/N;/Authorization:/d' ${TARGET_FILE}

	echo Security Definition added to ${TARGET_FILE} successfully
else
	echo Security Definition already exists. Nothing was added to ${TARGET_FILE}.
fi
