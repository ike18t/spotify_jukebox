require 'plaything'

class Plaything
  # Queue audio frames for playback.
  #
  # @param [Hash] format
  # @option format [Symbol] :sample_type should be :int16
  # @option format [Integer] :sample_rate
  # @option format [Integer] :channels
  # @param [FFI::Pointer<Integer] frames pointer to array of interleaved samples
  # @param [Integer] num_frames number of frames available in frames (same as num_samples / channels)
  # @return [Integer] number of frames consumed (consumed_samples / channels), a multiple of channels
  def stream(frame_format, frames, num_frames)
    synchronize do
      if buffers_processed > 0
        FFI::MemoryPointer.new(OpenAL::Buffer, buffers_processed) do |ptr|
          OpenAL.source_unqueue_buffers(@source, ptr.count, ptr)
          @total_buffers_processed += ptr.count
          @free_buffers.concat OpenAL::Buffer.extract(ptr, ptr.count)
          @queued_buffers.delete_if { |buffer| @free_buffers.include?(buffer) }
        end
      end

      self.format = frame_format if frame_format != format

      wanted_size = (@buffer_size - @queued_frames.length).div(@channels) * @channels
      available_size = num_frames * @channels
      readable_size = wanted_size > available_size ? available_size : wanted_size
      consumed_frames = frames.send(:"read_array_of_#{@sample_type}", readable_size)
      @queued_frames.concat(consumed_frames)

      if @queued_frames.length >= @buffer_size && @free_buffers.any?
        current_buffer = @free_buffers.shift

        FFI::MemoryPointer.new(@sample_type, @queued_frames.length) do |frames|
          frames.public_send(:"write_array_of_#{@sample_type}", @queued_frames)
          # stereo16 = 2 int16s (1 frame) = 1 sample
          OpenAL.buffer_data(current_buffer, @sample_format, frames, frames.size, @sample_rate)
          @queued_frames.clear
        end

        FFI::MemoryPointer.new(OpenAL::Buffer, 1) do |buffers|
          buffers.write_uint(current_buffer.to_native)
          OpenAL.source_queue_buffers(@source, buffers.count, buffers)
        end

        @queued_buffers.push(current_buffer)
      end

      consumed_frames.length / @channels
    end
  end
end
