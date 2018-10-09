package lolo.effects
{
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;

	/**
	 * AS的一些特效、样式
	 * @author LOLO
	 */
	public class AsEffect
	{
		/**
		 * 获取描边滤镜
		 * @param color 描边的颜色
		 * @return 
		 */
		public static function getStrokeFilter(color:uint = 0x000000):GlowFilter
		{
			return new GlowFilter(color, 1, 2, 2, 16);
		}
		
		
		/**
		 * 获取发光滤镜
		 * @param color 颜色
		 * @return 
		 */
		public static function getGlowFilter(color:uint = 0xFFFFCC):GlowFilter
		{
			return new GlowFilter(color);
		}
		
		
		/**黑白滤镜*/
		public static const GRAY_FILTER:ColorMatrixFilter = new ColorMatrixFilter([
			0.3086,	0.6094,	0.0820,	0,	0,
			0.3086,	0.6094,	0.0820,	0,	0,
			0.3086,	0.6094,	0.0820,	0,	0,
			0,		0,		0,		1,	0
		]);
		
		
		/**变亮颜色转换，亮度：0*/
		public static const LIGHT_CTF_0:ColorTransform = new ColorTransform();
		
		/**变亮颜色转换，亮度：20*/
		public static const LIGHT_CTF_2:ColorTransform = new ColorTransform(1, 1, 1, 1, 20, 20, 20, 0);
		
		/**变亮颜色转换，亮度：30*/
		public static const LIGHT_CTF_3:ColorTransform = new ColorTransform(1, 1, 1, 1, 30, 30, 30, 0);
		
		/**变亮颜色转换，亮度：40*/
		public static const LIGHT_CTF_4:ColorTransform = new ColorTransform(1, 1, 1, 1, 40, 40, 40, 0);
		
		
		/**选中时发光*/
		public static const SELECTED_GLOW_FILTER:Array = [new GlowFilter(0xFFFFCC, 0.6, 4, 4, 6)];
		//
	}
}