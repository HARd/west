package com.flashdynamix.motion.effects.core {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import com.flashdynamix.motion.effects.IEffect;	

	/**
	 * The ChannelEffect retrieves one or more channels from a source BitmapData and applies it to one
	 * or more destination BitmapData channels.
	 */
	public class ChannelEffect implements IEffect {

		/**
		 * The source BitmapData to copy a channel from.
		 */
		public var sourceBmd : BitmapData;
		/**
		 * The channel(s) to retrieve from the sourceBmd.<BR>
		 * You can use the bitwise OR operator (|) to combine channel values.
		 * <ul>
		 * <li>BitmapDataChannel.ALPHA : uint = 8</li>		 * <li>BitmapDataChannel.BLUE : uint = 4</li>		 * <li>BitmapDataChannel.GREEN : uint = 2</li>		 * <li>BitmapDataChannel.RED : uint = 1</li>
		 * </ul>
		 * i.e. BitmapDataChannel.RED | BitmapDataChannel.GREEN | BitmapDataChannel.BLUE will copy all channels except BitmapDataChannel.ALPHA 
		 */
		public var sourceChannel : uint;
		/**
		 * The channel to apply to the destination BitmapData.<BR>
		 * You can use the bitwise OR operator (|) to combine channel values.
		 * <ul>
		 * <li>BitmapDataChannel.ALPHA : uint = 8</li>
		 * <li>BitmapDataChannel.BLUE : uint = 4</li>
		 * <li>BitmapDataChannel.GREEN : uint = 2</li>
		 * <li>BitmapDataChannel.RED : uint = 1</li>
		 * </ul>
		 * i.e. BitmapDataChannel.RED | BitmapDataChannel.GREEN | BitmapDataChannel.BLUE will copy all channels except BitmapDataChannel.ALPHA 
		 */
		public var destChannel : uint;
		/**
		 * The clipping Rectangle area to retrieve the channel from.
		 */
		public var sourceRect : Rectangle;
		/**
		 * The position from which to retrieve the channel from.
		 */
		public var destPoint : Point;

		/**
		 * @param sourceBmd  The source BitmapData to copy a channel from.
		 * @param sourceChannel The channel(s) to retrieve from the sourceBmd.
		 * @param sourceRect The clipping Rectangle area to retrieve the channel within.
		 * @param destPoint The position from which to retrieve the channel from.
		 */
		function ChannelEffect(sourceBmd : BitmapData, sourceChannel : uint, destChannel : uint, sourceRect : Rectangle = null, destPoint : Point = null) {
			this.sourceBmd = sourceBmd;
			this.sourceChannel = sourceChannel;
			this.destChannel = destChannel;
			this.sourceRect = (sourceRect == null) ? sourceBmd.rect : sourceRect;
			this.destPoint = (destPoint == null) ? new Point() : destPoint;
		}

		/**
		 * Renders the ChannelEffect to the specified BitmapData.
		 */
		public function render(bmd : BitmapData) : void {
			bmd.copyChannel(sourceBmd, sourceRect, destPoint, sourceChannel, destChannel);
		}
	}
}
