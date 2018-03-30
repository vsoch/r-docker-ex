run: clean build

clean:
	rm -f r-singularity

build: clean
	sudo singularity build r-singularity Singularity
