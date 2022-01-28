#!/bin/bash
ROOT_DIR="D:\myTools\compress-videos-bulk\videos"
ENDWITH="_compress.mp4"
# TARGETSIZE=2000000000 # Target size(Bytes)
TARGETSIZE=1048576 # Target size(Bytes)

# The folder/subfolder/file name cannot contain spaces, otherwise the file cannot be traversed correctly!
read_dir(){
    for file in `ls -a $1`
    do
        if [ -d $1"/"$file ]
        then
            if [[ $file != '.' && $file != '..' ]]
            then
                read_dir $1"/"$file
            fi
        else
            if [ "${file##*.}"x = "mp4"x ]||[ "${file##*.}"x = "avi"x ]||[ "${file##*.}"x = "flv"x ]||[ "${file##*.}"x = "wmv"x ]||[ "${file##*.}"x = "mov"x ]
            then
                if [[ ${file:0-${#ENDWITH}} != $ENDWITH ]]; then
                    arr_videos=(${arr_videos[*]} ""$1"/"$file"")
                fi
            fi
        fi
    done
}

read_dir $ROOT_DIR
echo "Found ${#arr_videos[@]} videos"
process_done=0
echo "Start Compress..."
echo "---------------------------------"

for(( i=0;i<${#arr_videos[@]};i++)) do
    file_name=${arr_videos[i]##*/}
    file_pure_name=${file_name%%.*}
    file_father_path=${arr_videos[i]%/*}
    file_output="${file_father_path}/${file_pure_name}${ENDWITH}"
    echo "Compressing ${#arr_videos[@]} of num `expr $i + 1` video : ${arr_videos[i]}"
    video_bit_rate=`ffprobe -v quiet -select_streams v:0 -show_entries stream=bit_rate -of default=nw=1:nk=1 ${arr_videos[i]}`
    audio_bit_rate=`ffprobe -v quiet -select_streams a:0 -show_entries stream=bit_rate -of default=nw=1:nk=1 ${arr_videos[i]}`
    video_duration=`ffprobe -v quiet -select_streams v:0 -show_entries stream=duration -of default=nw=1:nk=1 ${arr_videos[i]}`
    # echo ${video_bit_rate}
    # echo ${audio_bit_rate}
    # echo ${video_duration}
    output_video_bit_rate=`echo "${TARGETSIZE}*8/${video_duration}-${audio_bit_rate}" | bc`
    # echo ${output_video_bit_rate}
    ffmpeg -i ${arr_videos[i]} -b:v ${output_video_bit_rate} -preset ultrafast -y ${file_output} >> output.log 2>&1

    if [ -f "${file_output}" ]; then
        echo "Video: ${file_output} generated successfully"
        process_done=`expr $process_done + 1`
        # rm -f ${arr_videos[i]}
    fi
done

echo "---------------------------------"
echo "Compressed ${process_done} of ${#arr_videos[@]} videos!"