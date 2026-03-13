#!/bin/bash

cd ../PeTTa/  || exit ;

echo "starting creating source";
sh run.sh ../metta-attention/experiments/data/create_source.metta -s > ../metta-attention/experiments/data/incident_out.metta;
sed -i '/^true$/d' ../metta-attention/experiments/data/incident_out.metta ;


echo "starting creating final";
sh run.sh ../metta-attention/experiments/data/create_incident.metta -s > ../metta-attention/experiments/data/incident_final.metta;
sed -i '/^true$/d' ../metta-attention/experiments/data/incident_final.metta ;
