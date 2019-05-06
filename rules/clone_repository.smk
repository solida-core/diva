
rule active_gatkdoc_plugin:
    output:
        touch("logs/multiqc/gatkdoc_plugin_activation.done")

    params:
        repo=config.get("repository").get("gatkdoc_plugin")

    shell:
        "git clone {params.repo} && cd gatkdoc_plugin && python setup.py install "