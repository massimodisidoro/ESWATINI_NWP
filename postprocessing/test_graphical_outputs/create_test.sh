#!/bin/bash

export dir_post="/storage/forecast_system/ESWATINI_NWP//postprocessing"

# ask if delete old figuresproduced with test
read -p "Please, type a name for your working directory to be automatically  created (no special characters except _ ).
       you can use also an existing one: " working_dir
if [[ -n $working_dir ]];then
  if [[ -d $working_dir ]];then
    # ask if delete old figuresproduced with test
    read -p "Do you want to remove previous test figures (if any) in the working folder before proceeding?  (Y/N): " response
    
    if [[ "$response" == "Y" || "$response" == "y"  ]]; then
      # Effettua l'azione di cancellazione delle figure
      rm -f $working_dir/* &> /dev/null
      echo "Figures deleted"
    else
      echo "Proceed without deleing old figures..."
    fi
  fi
  mkdir -p $working_dir
else
  echo "working folder name not provided. EXIT"
  exit 1
fi


cp test.sh $working_dir
cp $dir_post/*.py   $working_dir
cp $dir_post/*.R   $working_dir
cp *.TS  tslist *yaml*  test.sh $working_dir
cp $dir_post/README_POSTPROCESSING $working_dir

cd $working_dir
ln -sf ../wrfout* .
cd - &>/dev/null
