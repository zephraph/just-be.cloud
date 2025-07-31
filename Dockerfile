FROM ghcr.io/pomdtr/smallweb:0.28.2

# Create the smallweb directory
RUN mkdir -p /smallweb

# Set working directory
WORKDIR /smallweb

# Copy all smallweb apps and configuration
COPY . /smallweb/

# Initialize smallweb with the domain
RUN smallweb init --domain just-be.cloud

# Expose the default smallweb port
EXPOSE 7777

# Start smallweb
CMD ["up"]