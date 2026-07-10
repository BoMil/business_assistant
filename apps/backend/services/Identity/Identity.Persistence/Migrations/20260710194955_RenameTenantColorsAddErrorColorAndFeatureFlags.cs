using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Identity.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class RenameTenantColorsAddErrorColorAndFeatureFlags : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Existing SecondaryColor data is semantically the accent color — preserve it
            // under the new name instead of losing it under an unrelated column.
            migrationBuilder.RenameColumn(
                name: "SecondaryColor",
                table: "Tenants",
                newName: "AccentColor");

            migrationBuilder.AddColumn<string>(
                name: "ErrorColor",
                table: "Tenants",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "#eb2e25");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ErrorColor",
                table: "Tenants");

            migrationBuilder.RenameColumn(
                name: "AccentColor",
                table: "Tenants",
                newName: "SecondaryColor");
        }
    }
}
