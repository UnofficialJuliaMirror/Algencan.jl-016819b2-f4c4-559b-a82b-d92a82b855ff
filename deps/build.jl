using BinDeps

# TODO: Allow using HSL

@BinDeps.setup

libalgencan = library_dependency("libalgencan")

udir = "algencan-3.0.0"
algencan_dirname = joinpath(BinDeps.depsdir(libalgencan), "src", udir)

#provides(Sources, URI("url"), libalgencan, unpacked_dir=udir)

# Download
provides(SimpleBuild,
         (@build_steps begin
            # Download and untar
            #GetSources(libalgencan) # Fix url
            ChangeDirectory(BinDeps.depsdir(libalgencan))        # Possibly remove
            CreateDirectory("src")
            CreateDirectory("usr")
            CreateDirectory("usr/lib")
            `tar -zxf downloads/algencan-3.0.0-beta.tgz -C src/` # Remove this later
            @build_steps begin
              ChangeDirectory(algencan_dirname)
              # Compile with Makefile and flags
              `make CFLAGS="-O3 -fPIC" FFLAGS="-O3 -ffree-form -fPIC"`
              # Produce a shared library on deps/usr/lib
              `gcc -shared -o ../../usr/lib/libalgencan.so
                    -Wl,--whole-archive lib/libalgencan.a
                    -Wl,--no-whole-archive -lgfortran`
            end
          end), libalgencan, os = :Unix)

@BinDeps.install Dict(:libalgencan => :libalgencan)