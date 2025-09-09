#!/bin/bash

log_dir=$1
touch -c "$log_dir"/*
ls -la "$log_dir"