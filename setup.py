import setuptools

setuptools.setup(
    name='dataflow-demo',
    version='0.1.0',
    install_requires=[
        'apache-beam[gcp]',
        'fastavro',
    ],
    packages=setuptools.find_packages(),
    py_modules=['dataflow_utils'],
)
