#!/bin/bash

SRC_DIR=`dirname "$0"`
OUTPUT_FILE=$SRC_DIR/kernel-config.h
FEATURE_TEST_DIR="$SRC_DIR/configure-tests/feature-tests"
FEATURE_TEST_FILES="$FEATURE_TEST_DIR/*.c"
SYMBOL_TESTS_FILE="$SRC_DIR/configure-tests/symbol-tests"

echo "generating configurations"

rm -f $OUTPUT_FILE

echo "//The values in this file should be generated by the build process. Do not alter." >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo "#ifndef DATTOBD_KERNEL_CONFIG_H" >> $OUTPUT_FILE
echo "#define DATTOBD_KERNEL_CONFIG_H" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

make -s -C $FEATURE_TEST_DIR clean

for TEST_FILE in $FEATURE_TEST_FILES
do
	TEST="$(basename $TEST_FILE .c)"
	OBJ="$TEST.o"
	MACRO_NAME="HAVE_$(echo ${TEST} | awk '{print toupper($0)}')"
	echo -n "performing configure test: $MACRO_NAME - "
	if make -C $FEATURE_TEST_DIR OBJ=$OBJ &>/dev/null ; then
		echo "present"
		echo "#define $MACRO_NAME" >> $OUTPUT_FILE
	else
		echo "not present"
	fi
done

make -s -C $FEATURE_TEST_DIR clean

while read SYMBOL_NAME; do
	if [ -z $SYMBOL_NAME ]; then
		continue
	fi
	
	echo "performing $SYMBOL_NAME lookup"
	MACRO_NAME="$(echo ${SYMBOL_NAME} | awk '{print toupper($0)}')_ADDR"
	SYMBOL_ADDR=$(grep -w $SYMBOL_NAME "/boot/System.map-$1" | awk '{print $1}')
	if [ -z $SYMBOL_ADDR ]; then
		SYMBOL_ADDR="0"
	fi
	echo "#define $MACRO_NAME 0x$SYMBOL_ADDR" >> $OUTPUT_FILE
done < $SYMBOL_TESTS_FILE

echo "" >> $OUTPUT_FILE
echo "#endif" >> $OUTPUT_FILE
