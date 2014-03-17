import glob

#INPUTS
PROJECT_DIR = "/net/eichler/vol17/dutch_aspergers/nobackup/conifer_test"
BAM_SAMPLE_LIST = "samples_03-04-14.txt"
BAM_SAMPLE_BATCH_PREFIX = "sample_"
SVD_DISCARD = 9 # This parameter requires tuning

samples = []
with open(PROJECT_DIR + "/" +  BAM_SAMPLE_LIST, "r") as sample_list:
    for line in sample_list:
        samples.append(line.split()[0])
samples = samples[1:]

#END_INPUTS

rule calcrpkm:
    input: {PROJECT_DIR}"/hdf5/{samples}.h5"
    shell: "./calc_rpkm.sh"

rule submit_frfast:
    input: "mrfast_template_original.txt", {BAM_SAMPLE_LIST}
    output: expand("%s/hdf5/{samples}.h5" % PROJECT_DIR, samples=samples)
    params: frfast_batches = 5
    shell: "./run_batch_frfast.sh %s" % frfast_batches

rule setup_project_env:
    shell: "pushd {PROJECT_DIR}; mkdir -p hdf5 logs calls plots rpkm; popd"
